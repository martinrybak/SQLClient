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
	LOGINREC* _login;
	DBPROCESS* _connection;
	char* _password;
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
			return;
		}
		
		//Switch to database
		RETCODE code = dbuse(_connection, [self.database UTF8String]);
		if (code == FAIL) {
			[self connectionFailure:completion];
			return;
		}
	
		//Success!
		[self connectionSuccess:completion];
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
				return;
			}
			
			int numColumns;
			struct COL* columns;
			struct COL* currentColumn;
			STATUS rowCode;
						
			//Create array to contain the rows for this table
			NSMutableArray* table = [NSMutableArray array];
			
			//Get number of columns
			numColumns = dbnumcols(_connection);
			
			//Allocate C-style array of COL structs
			columns = calloc(numColumns, sizeof(struct COL));
			if (!columns) {
				[self executionFailure:completion];
				return;
			}
			
			//Bind the column info
			for (currentColumn = columns; currentColumn - columns < numColumns; currentColumn++)
			{
				//Get column number
				int c = currentColumn - columns + 1;
				
				//Get column metadata
				currentColumn->name = dbcolname(_connection, c);
				currentColumn->type = dbcoltype(_connection, c);
				currentColumn->size = dbcollen(_connection, c);
				
				//Create buffer for column data
				currentColumn->buffer = calloc(1, currentColumn->size);
				if (!currentColumn->buffer) {
					[self executionFailure:completion];
					return;
				}
				
				//Set bind type based on column type
				int varType = 0;
				switch (currentColumn->type)
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
					case SYBDATE:
					case SYBTIME:
					case SYBBIGDATETIME:
					case SYBBIGTIME:
					case SYBMSDATE:
					case SYBMSTIME:
					case SYBMSDATETIME2:
					case SYBMSDATETIMEOFFSET:
					{
						//TODO
						break;
					}
					case SYBBINARY:
					case SYBVOID:
					case SYBVARBINARY:
					case SYBIMAGE:
					{
						varType = BINARYBIND;
						break;
					}
				}

				//Bind column data
				RETCODE returnCode = dbbind(_connection, c, varType, currentColumn->size, currentColumn->buffer);
				if (returnCode == FAIL) {
					[self executionFailure:completion];
					return;
				}
				
				//Bind null value into column status
				returnCode = dbnullbind(_connection, c, &currentColumn->status);
				if (returnCode == FAIL) {
					[self executionFailure:completion];
					return;
				}
				
				//printf("%s is type %d with value %s\n", pcol->name, pcol->type, pcol->buffer);
			}
			
			//printf("\n");
			
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
						for (currentColumn = columns; currentColumn - columns < numColumns; currentColumn++)
						{
							id value;
							
							if (currentColumn->status == -1) { //null value
								value = [NSNull null];
							} else {
								switch (currentColumn->type)
								{
									case SYBBIT: //0 or 1
									{
										BOOL _value;
										memcpy(&_value, currentColumn->buffer, sizeof _value);
										value = [NSNumber numberWithBool:_value];
										break;
									}
									case SYBINT1: //Whole numbers from 0 to 255
									case SYBINT2: //Whole numbers between -32,768 and 32,767
									case SYBINT4: //Whole numbers between -2,147,483,648 and 2,147,483,647
									{
										int32_t _value;
										memcpy(&_value, currentColumn->buffer, sizeof _value);
										value = [NSNumber numberWithInt:_value];
										break;
									}
									case SYBINT8: //Whole numbers between -9,223,372,036,854,775,808 and 9,223,372,036,854,775,807
									{
										long long _value;
										memcpy(&_value, currentColumn->buffer, sizeof _value);
										value = [NSNumber numberWithLongLong:_value];
										break;
									}
									case SYBFLT8: //Floating precision number data from -1.79E + 308 to 1.79E + 308
									{
										double _value;
										memcpy(&_value, currentColumn->buffer, sizeof _value);
										value = [NSNumber numberWithDouble:_value];
										break;
									}
									case SYBREAL: //Floating precision number data from -3.40E + 38 to 3.40E + 38
									{
										float _value;
										memcpy(&_value, currentColumn->buffer, sizeof _value);
										value = [NSNumber numberWithFloat:_value];
										break;
									}
									case SYBMONEY4: //Monetary data from -214,748.3648 to 214,748.3647
									{
										DBMONEY4 _money;
										memcpy(&_money, currentColumn->buffer, sizeof _money);
										NSNumber* _value = @(_money.mny4);
										NSDecimalNumber* decimalNumber = [NSDecimalNumber decimalNumberWithString:[_value description]];
										value = [decimalNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10000"]];
										break;
									}
									case SYBMONEY: //Monetary data from -922,337,203,685,477.5808 to 922,337,203,685,477.5807
									{
										BYTE* string = calloc(20, sizeof(BYTE)); //Max string length is 20
										dbconvert(_connection, SYBMONEY, currentColumn->buffer, sizeof(SYBMONEY), SYBCHAR, string, -1);
										value = [NSDecimalNumber decimalNumberWithString:[NSString stringWithUTF8String:(char*)string]];
										free(string);
										break;
									}
									case SYBDECIMAL: //Numbers from -10^38 +1 to 10^38 –1.
									case SYBNUMERIC:
									{
										NSString* _value = [[NSString alloc] initWithUTF8String:(char*)currentColumn->buffer];
										value = [NSDecimalNumber decimalNumberWithString:_value];
										break;
									}
									case SYBCHAR:
									case SYBVARCHAR:
									case SYBNVARCHAR:
									case SYBTEXT:
									case SYBNTEXT:
									{
										value = [NSString stringWithUTF8String:(char*)currentColumn->buffer];
										break;
									}
									case SYBDATETIME:
									case SYBDATETIME4:
									case SYBDATETIMN:
									case SYBDATE:
									case SYBTIME:
									case SYBBIGDATETIME:
									case SYBBIGTIME:
									case SYBMSDATE:
									case SYBMSTIME:
									case SYBMSDATETIME2:
									case SYBMSDATETIMEOFFSET:
									{
										//TODO
										//NSDate
										break;
									}
									case SYBVOID:
									case SYBBINARY:
									case SYBVARBINARY:
									{
										value = [NSData dataWithBytes:currentColumn->buffer length:currentColumn->size];
										break;
									}
									case SYBIMAGE:
									{
										NSData* data = [NSData dataWithBytes:currentColumn->buffer length:currentColumn->size];
										value = [UIImage imageWithData:data];
										break;
									}
								}
							}
							
							//id value = [NSString stringWithUTF8String:pcol->buffer] ?: [NSNull null];
							NSString* column = [NSString stringWithUTF8String:currentColumn->name];
							row[column] = value;
                            //printf("%@=%@\n", column, value);
						}
                        
                        //Add an immutable copy to the table
						[table addObject:[row copy]];
						//printf("\n");
						break;
					}
					//Buffer full
					case BUF_FULL:
						[self executionFailure:completion];
						return;
					//Error
					case FAIL:
						[self executionFailure:completion];
						return;
					default:
						[self message:SQLClientRowIgnoreMessage];
						break;
				}
			}
			
			//Clean up
			for (currentColumn = columns; currentColumn - columns < numColumns; currentColumn++) {
				free(currentColumn->buffer);
			}
			free(columns);
			
			//Add immutable copy of table to output
			[output addObject:[table copy]];
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

#pragma mark - Private

//Invokes connection completion handler on callback queue with success = NO
- (void)connectionFailure:(void (^)(BOOL success))completion
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion(NO);
		}
    }];
    
    //Cleanup
    dbloginfree(_login);
	free(_password);
}

//Invokes connection completion handler on callback queue with success = [self connected]
- (void)connectionSuccess:(void (^)(BOOL success))completion
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion([self isConnected]);
		}
    }];
    
    //Cleanup
    dbloginfree(_login);
	free(_password);
}

//Invokes execution completion handler on callback queue with results = nil
- (void)executionFailure:(void (^)(NSArray* results))completion
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion(nil);
		}
    }];
    
    //Clean up
    dbfreebuf(_connection);
}

//Invokes execution completion handler on callback queue with results array
- (void)executionSuccess:(void (^)(NSArray* results))completion results:(NSArray*)results
{
    [self.callbackQueue addOperationWithBlock:^{
		if (completion) {
            completion(results);
		}
    }];
    
    //Clean up
    dbfreebuf(_connection);
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

@end
