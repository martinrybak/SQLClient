//
//  SQLClient.m
//  SQLClient
//
//  Created by Martin Rybak on 10/4/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "SQLClient.h"
#import "sybfront.h"
#import "sybdb.h"
#import "syberror.h"

#define SYBUNIQUEIDENTIFIER 36

int const SQLClientDefaultTimeout = 5;
int const SQLClientDefaultQueryTimeout = 5;
NSString* const SQLClientDefaultCharset = @"UTF-8";
NSString* const SQLClientWorkerQueueName = @"com.martinrybak.sqlclient";
NSString* const SQLClientDelegateError = @"Delegate must be set to an NSObject that implements the SQLClientDelegate protocol";
NSString* const SQLClientRowIgnoreMessage = @"Ignoring unknown row type";

struct COL
{
	char* name;
	BYTE* buffer;
	int type;
	int size;
	int status;
};

@interface SQLClient ()

@property (nonatomic, copy, readwrite) NSString* host;
@property (nonatomic, copy, readwrite) NSString* username;
@property (nonatomic, copy, readwrite) NSString* database;

@end

@implementation SQLClient
{
	char* _password;
	LOGINREC* _login;
	DBPROCESS* _connection;
	struct COL* _columns;
}

#pragma mark - NSObject

//Initializes the FreeTDS library and sets callback handlers
- (id)init
{
    if (self = [super init])
    {
        //Initialize the FreeTDS library
		if (dbinit() == FAIL) {
			return nil;
		}
		
		//Initialize SQLClient
		self.timeout = SQLClientDefaultTimeout;
		self.charset = SQLClientDefaultCharset;
		self.callbackQueue = [NSOperationQueue currentQueue];
		self.workerQueue = [[NSOperationQueue alloc] init];
		self.workerQueue.name = SQLClientWorkerQueueName;
		
        //Set FreeTDS callback handlers
        dberrhandle(err_handler);
        dbmsghandle(msg_handler);
    }
    return self;
}

//Exits the FreeTDS library
- (void)dealloc
{
    dbexit();
}

#pragma mark - Public

+ (instancetype)sharedInstance
{
    static SQLClient* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)connect:(NSString*)host
	   username:(NSString*)username
	   password:(NSString*)password
	   database:(NSString*)database
	 completion:(void (^)(BOOL success))completion
{
	//Save inputs
	self.host = host;
	self.username = username;
	self.database = database;

	/*
	Copy password into a global C string. This is because in connectionSuccess: and connectionFailure:,
	dbloginfree() will attempt to overwrite the password in the login struct with zeroes for security.
	So it must be a string that stays alive until then. Passing in [password UTF8String] does not work because:
		 
	"The returned C string is a pointer to a structure inside the string object, which may have a lifetime
	shorter than the string object and will certainly not have a longer lifetime. Therefore, you should
	copy the C string if it needs to be stored outside of the memory context in which you called this method."
	https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/Reference/NSString.html#//apple_ref/occ/instm/NSString/UTF8String
	 */
	 _password = strdup([password UTF8String]);
	
	//Connect to database on worker queue
	[self.workerQueue addOperationWithBlock:^{
	
		//Set login timeout
		dbsetlogintime(self.timeout);
		
		//Initialize login struct
		_login = dblogin();
		if (_login == FAIL) {
			[self connectionFailure:completion];
			[self cleanupAfterConnection];
			return;
		}
		
		//Populate login struct
		DBSETLUSER(_login, [self.username UTF8String]);
		DBSETLPWD(_login, _password);
		DBSETLHOST(_login, [self.host UTF8String]);
		DBSETLCHARSET(_login, [self.charset UTF8String]);
		
		//Connect to database server
		_connection = dbopen(_login, [self.host UTF8String]);
		if (!_connection) {
			[self connectionFailure:completion];
			[self cleanupAfterConnection];
			return;
		}
		
		//Switch to database, if provided
		if (self.database) {
			RETCODE code = dbuse(_connection, [self.database UTF8String]);
			if (code == FAIL) {
				[self connectionFailure:completion];
				[self cleanupAfterConnection];
				return;
			}
		}
	
		//Success!
		[self connectionSuccess:completion];
		[self cleanupAfterConnection];
	}];
}

- (BOOL)isConnected
{
	return !dbdead(_connection);
}

// TODO: how to get number of records changed during update or delete
// TODO: how to handle SQL stored procedure output parameters
- (void)execute:(NSString*)sql completion:(void (^)(NSArray* results))completion
{
	//Execute query on worker queue
	[self.workerQueue addOperationWithBlock:^{
		
		//Set query timeout
		dbsettime(self.timeout);
		
		//Prepare SQL statement
		dbcmd(_connection, [sql UTF8String]);
		
		//Execute SQL statement
		if (dbsqlexec(_connection) == FAIL) {
			[self executionFailure:completion];
			[self cleanupAfterExecution:0];
			return;
		}
		
		//Create array to contain the tables
		NSMutableArray* output = [NSMutableArray array];
		
		//Loop through each table metadata
		//dbresults() returns SUCCEED, FAIL or, NO_MORE_RESULTS.
		RETCODE returnCode;
		while ((returnCode = dbresults(_connection)) != NO_MORE_RESULTS)
		{
			if (returnCode == FAIL) {
				[self executionFailure:completion];
				[self cleanupAfterExecution:0];
				return;
			}
			
			int numColumns;
			struct COL* column;
			STATUS rowCode;
						
			//Create array to contain the rows for this table
			NSMutableArray* table = [NSMutableArray array];
			
			//Get number of columns
			numColumns = dbnumcols(_connection);
			
			//Allocate C-style array of COL structs
			_columns = calloc(numColumns, sizeof(struct COL));
			if (!_columns) {
				[self executionFailure:completion];
				[self cleanupAfterExecution:0];
				return;
			}
			
			//Bind the column info
			for (column = _columns; column - _columns < numColumns; column++)
			{
				//Get column number
				int c = column - _columns + 1;
				
				//Get column metadata
				column->name = dbcolname(_connection, c);
				column->type = dbcoltype(_connection, c);
				column->size = dbcollen(_connection, c);
				
				//Create buffer for column data
				column->buffer = calloc(1, column->size);
				if (!column->buffer) {
					[self executionFailure:completion];
					[self cleanupAfterExecution:numColumns];
					return;
				}
				
				//Set bind type based on column type
				int varType = CHARBIND; //Default
				switch (column->type)
				{
					case SYBBIT:
					case SYBBITN:
					{
						varType = BITBIND;
						break;
					}
					case SYBINT1:
					{
						varType = TINYBIND;
						break;
					}
					case SYBINT2:
					{
						varType = SMALLBIND;
						break;
					}
					case SYBINT4:
					case SYBINTN:
					{
						varType = INTBIND;
						break;
					}
					case SYBINT8:
					{
						varType = BIGINTBIND;
						break;
					}
					case SYBFLT8:
					case SYBFLTN:
					{
						varType = FLT8BIND;
						break;
					}
					case SYBREAL:
					{
						varType = REALBIND;
						break;
					}
					case SYBMONEY4:
					{
						varType = SMALLMONEYBIND;
						break;
					}
					case SYBMONEY:
					case SYBMONEYN:
					{
						varType = MONEYBIND;
						break;
					}
					case SYBDECIMAL:
					case SYBNUMERIC:
					case SYBCHAR:
					case SYBVARCHAR:
					case SYBNVARCHAR:
					case SYBTEXT:
					case SYBNTEXT:
					{
						varType = NTBSTRINGBIND;
						break;
					}
					case SYBDATETIME:
					case SYBDATETIME4:
					case SYBDATETIMN:
					case SYBBIGDATETIME:
					case SYBBIGTIME:
					//FreeTDS incorrectly identifies the following types as SYBCHAR:
					case SYBDATE:
					case SYBTIME:
					case SYBMSDATE:
					case SYBMSTIME:
					case SYBMSDATETIME2:
					case SYBMSDATETIMEOFFSET:
					{
						varType = DATETIMEBIND;
						break;
					}
					case SYBVOID:
					case SYBBINARY:
					case SYBVARBINARY:
					case SYBIMAGE:
					case SYBUNIQUEIDENTIFIER:
					{
						varType = BINARYBIND;
						break;
					}
				}

				//Bind column data
				RETCODE returnCode = dbbind(_connection, c, varType, column->size, column->buffer);
				if (returnCode == FAIL) {
					[self executionFailure:completion];
					[self cleanupAfterExecution:numColumns];
					return;
				}
				
				//Bind null value into column status
				returnCode = dbnullbind(_connection, c, &column->status);
				if (returnCode == FAIL) {
					[self executionFailure:completion];
					[self cleanupAfterExecution:numColumns];
					return;
				}
			}
			
			//Loop through each row
			while ((rowCode = dbnextrow(_connection)) != NO_MORE_ROWS)
			{
				//Check row type
				switch (rowCode)
				{
					//Regular row
					case REG_ROW:
					{
						//Create a new dictionary to contain the column names and vaues
						NSMutableDictionary* row = [[NSMutableDictionary alloc] initWithCapacity:numColumns];
						
						//Loop through each column and create an entry where dictionary[columnName] = columnValue
						for (column = _columns; column - _columns < numColumns; column++)
						{
							//Default to null
							id value = [NSNull null];
							
							switch (column->type)
							{
								case SYBBIT: //0 or 1
								{
									BOOL _value;
									memcpy(&_value, column->buffer, sizeof _value);
									value = [NSNumber numberWithBool:_value];
									break;
								}
								case SYBINT1: //Whole numbers from 0 to 255
								case SYBINT2: //Whole numbers between -32,768 and 32,767
								case SYBINT4: //Whole numbers between -2,147,483,648 and 2,147,483,647
								{
									int32_t _value;
									memcpy(&_value, column->buffer, sizeof _value);
									value = [NSNumber numberWithInt:_value];
									break;
								}
								case SYBINT8: //Whole numbers between -9,223,372,036,854,775,808 and 9,223,372,036,854,775,807
								{
									long long _value;
									memcpy(&_value, column->buffer, sizeof _value);
									value = [NSNumber numberWithLongLong:_value];
									break;
								}
								case SYBFLT8: //Floating precision number data from -1.79E + 308 to 1.79E + 308
								{
									double _value;
									memcpy(&_value, column->buffer, sizeof _value);
									value = [NSNumber numberWithDouble:_value];
									break;
								}
								case SYBREAL: //Floating precision number data from -3.40E + 38 to 3.40E + 38
								{
									float _value;
									memcpy(&_value, column->buffer, sizeof _value);
									value = [NSNumber numberWithFloat:_value];
									break;
								}
								case SYBMONEY4: //Monetary data from -214,748.3648 to 214,748.3647
								{
									DBMONEY4 _value;
									memcpy(&_value, column->buffer, sizeof _value);
									NSNumber* number = @(_value.mny4);
									NSDecimalNumber* decimalNumber = [NSDecimalNumber decimalNumberWithString:[number description]];
									value = [decimalNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10000"]];
									break;
								}
								case SYBMONEY: //Monetary data from -922,337,203,685,477.5808 to 922,337,203,685,477.5807
								{
									BYTE* _value = calloc(20, sizeof(BYTE)); //Max string length is 20
									dbconvert(_connection, SYBMONEY, column->buffer, sizeof(SYBMONEY), SYBCHAR, _value, -1);
									value = [NSDecimalNumber decimalNumberWithString:[NSString stringWithUTF8String:(char*)_value]];
									free(_value);
									break;
								}
								case SYBDECIMAL: //Numbers from -10^38 +1 to 10^38 –1.
								case SYBNUMERIC:
								{
									NSString* _value = [[NSString alloc] initWithUTF8String:(char*)column->buffer];
									value = [NSDecimalNumber decimalNumberWithString:_value];
									break;
								}
								case SYBCHAR:
								case SYBVARCHAR:
								case SYBNVARCHAR:
								case SYBTEXT:
								case SYBNTEXT:
								{
									value = [NSString stringWithUTF8String:(char*)column->buffer];
									break;
								}
								case SYBDATETIME:
								case SYBDATETIME4:
								case SYBDATETIMN:
								case SYBBIGDATETIME:
								case SYBBIGTIME:
								{
									DBDATETIME _value;
									memcpy(&_value, column->buffer, sizeof _value);
									NSTimeInterval daysSinceReferenceDate = (NSTimeInterval)_value.dtdays; //Days are counted from 1/1/1900
									NSTimeInterval secondsSinceReferenceDate = daysSinceReferenceDate * 24 * 60 * 60;
									NSTimeInterval secondsSinceMidnight = _value.dttime / 3000;			   //Time is in increments of 3.33 milliseconds
									value = [NSDate dateWithTimeInterval:secondsSinceReferenceDate + secondsSinceMidnight sinceDate:[self referenceDate]];
									break;
								}
								case SYBVOID:
								case SYBBINARY:
								case SYBVARBINARY:
								{
									value = [NSData dataWithBytes:column->buffer length:column->size];
									break;
								}
								case SYBIMAGE:
								{
									NSData* data = [NSData dataWithBytes:column->buffer length:column->size];
									value = [UIImage imageWithData:data];
									break;
								}
								case SYBUNIQUEIDENTIFIER: //https://en.wikipedia.org/wiki/Globally_unique_identifier#Binary_encoding
								{
									value = [[NSUUID alloc] initWithUUIDBytes:column->buffer];
									break;
								}
							}
							
							NSString* columnName = [NSString stringWithUTF8String:column->name];
							row[columnName] = value;
						}
                        
                        //Add an immutable copy to the table
						[table addObject:[row copy]];
						break;
					}
					//Buffer full
					case BUF_FULL:
						[self executionFailure:completion];
						[self cleanupAfterExecution:numColumns];
						return;
					//Error
					case FAIL:
						[self executionFailure:completion];
						[self cleanupAfterExecution:numColumns];
						return;
					default:
						[self message:SQLClientRowIgnoreMessage];
						break;
				}
			}

			//Add immutable copy of table to output
			[output addObject:[table copy]];
			[self cleanupAfterExecution:numColumns];
		}
		
        //Success! Send an immutable copy of the results array
		[self executionSuccess:completion results:[output copy]];
	}];
}

- (void)disconnect
{
	[self.workerQueue addOperationWithBlock:^{
		dbclose(_connection);
	}];
}

#pragma mark - FreeTDS Callbacks

//Handles message callback from FreeTDS library.
int msg_handler(DBPROCESS* dbproc, DBINT msgno, int msgstate, int severity, char* msgtext, char* srvname, char* procname, int line)
{
	//Can't call self from a C function, so need to access singleton
	SQLClient* self = [SQLClient sharedInstance];
	[self message:[NSString stringWithUTF8String:msgtext]];
	return 0;
}

//Handles error callback from FreeTDS library.
int err_handler(DBPROCESS* dbproc, int severity, int dberr, int oserr, char* dberrstr, char* oserrstr)
{
	//Can't call self from a C function, so need to access singleton
	SQLClient* self = [SQLClient sharedInstance];
	[self error:[NSString stringWithUTF8String:dberrstr] code:dberr severity:severity];
	return INT_CANCEL;
}

//Forwards a message to the delegate on the callback queue if it implements
- (void)message:(NSString*)message
{
	//Invoke delegate on calling queue
	[self.callbackQueue addOperationWithBlock:^{
		if ([self.delegate respondsToSelector:@selector(message:)]) {
			[self.delegate message:message];
		}
	}];
}

//Forwards an error message to the delegate on the callback queue.
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
	//Invoke delegate on callback queue
	[self.callbackQueue addOperationWithBlock:^{
		if (![self.delegate conformsToProtocol:@protocol(SQLClientDelegate)]) {
			[NSException raise:SQLClientDelegateError format:nil];
		}
		[self.delegate error:error code:code severity:severity];
	}];
}

#pragma mark - Cleanup

- (void)cleanupAfterConnection
{
	dbloginfree(_login);
	if (_password) {
		free(_password);
	}
}

- (void)cleanupAfterExecution:(int)numColumns
{
	struct COL* column;
	for (column = _columns; column - _columns < numColumns; column++) {
		if (column->buffer) {
			free(column->buffer);
		}
	}
	if (_columns) {
		free(_columns);
	}
	dbfreebuf(_connection);
}

#pragma mark - Private

//Invokes connection completion handler on callback queue with success = NO
- (void)connectionFailure:(void (^)(BOOL success))completion
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion(NO);
		}
    }];
}

//Invokes connection completion handler on callback queue with success = [self connected]
- (void)connectionSuccess:(void (^)(BOOL success))completion
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion([self isConnected]);
		}
    }];
}

//Invokes execution completion handler on callback queue with results = nil
- (void)executionFailure:(void (^)(NSArray* results))completion
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion(nil);
		}
    }];
}

//Invokes execution completion handler on callback queue with results array
- (void)executionSuccess:(void (^)(NSArray* results))completion results:(NSArray*)results
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion(results);
		}
    }];
}

#pragma mark - Reference Date

//January 1, 1900
- (NSDate*)referenceDate
{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
	dateComponents.year = 1900;
	dateComponents.month = 1;
	dateComponents.day = 1;
	return [calendar dateFromComponents:dateComponents];
}

@end
