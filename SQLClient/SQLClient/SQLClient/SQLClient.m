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
int const SQLClientDefaultMaxTextSize = 4096;
NSString* const SQLClientDefaultCharset = @"UTF-8";
NSString* const SQLClientWorkerQueueName = @"com.martinrybak.sqlclient";
NSString* const SQLClientPendingConnectionError = @"Attempting to connect while a connection is active.";
NSString* const SQLClientNoConnectionError = @"Attempting to execute while not connected.";
NSString* const SQLClientPendingExecutionError = @"Attempting to execute while a command is in progress.";
NSString* const SQLClientRowIgnoreMessage = @"Ignoring unknown row type";
NSString* const SQLClientMessageNotification = @"SQLClientMessageNotification";
NSString* const SQLClientErrorNotification = @"SQLClientErrorNotification";
NSString* const SQLClientMessageKey = @"SQLClientMessageKey";
NSString* const SQLClientCodeKey = @"SQLClientCodeKey";
NSString* const SQLClientSeverityKey = @"SQLClientSeverityKey";

struct GUID {
	unsigned long  data1;
	unsigned short data2;
	unsigned short data3;
	unsigned char  data4[8];
};

struct COLUMN
{
	char* name;
	int type;
	int size;
	int status;
	BYTE* data;
};

@interface SQLClient ()

@property (nonatomic, strong) NSOperationQueue* workerQueue;
@property (nonatomic, weak) NSOperationQueue* callbackQueue;
@property (atomic, assign, getter=isExecuting) BOOL executing;

@end

@implementation SQLClient
{
	char* _password;
	LOGINREC* _login;
	DBPROCESS* _connection;
	struct COLUMN* _columns;
	int _numColumns;
	RETCODE _returnCode;
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
		self.workerQueue.maxConcurrentOperationCount = 1;
		self.maxTextSize = SQLClientDefaultMaxTextSize;
		self.executing = NO;
		
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

+ (nullable instancetype)sharedInstance
{
    static SQLClient* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)connect:(nonnull NSString*)host
	   username:(nonnull NSString*)username
	   password:(nonnull NSString*)password
	   database:(nullable NSString*)database
	 completion:(nullable void(^)(BOOL success))completion
{
	NSParameterAssert(host);
	NSParameterAssert(username);
	NSParameterAssert(password);
	
	//Connect to database on worker queue
	[self.workerQueue addOperationWithBlock:^{
	
		if (self.isConnected) {
			[self message:SQLClientPendingConnectionError];
			[self connectionFailure:completion];
			return;
		}
				
		/*
		 Copy password into a global C string. This is because in cleanupAfterConnection,
		 dbloginfree() will attempt to overwrite the password in the login struct with zeroes for security.
		 So it must be a string that stays alive until then.
		 */
		 _password = strdup([password UTF8String]);
		
		//Initialize login struct
		_login = dblogin();
		if (_login == FAIL) {
			[self connectionFailure:completion];
			return;
		}
		
		//Populate login struct
		DBSETLUSER(_login, [username UTF8String]);
		DBSETLPWD(_login, _password);
		DBSETLHOST(_login, [host UTF8String]);
		DBSETLCHARSET(_login, [self.charset UTF8String]);
		
		//Set login timeout
		dbsetlogintime(self.timeout);
		
		//Connect to database server
		_connection = dbopen(_login, [host UTF8String]);
		if (!_connection) {
			[self connectionFailure:completion];
			return;
		}
		
		//Switch to database, if provided
		if (database) {
			_returnCode = dbuse(_connection, [database UTF8String]);
			if (_returnCode == FAIL) {
				[self connectionFailure:completion];
				return;
			}
		}
	
		//Success!
		[self connectionSuccess:completion];
	}];
}

- (BOOL)isConnected
{
	return !dbdead(_connection);
}

// TODO: get number of records modified for insert/update/delete commands
// TODO: handle SQL stored procedure output parameters
- (void)execute:(nonnull NSString*)sql completion:(nullable void(^)(NSArray* _Nullable results))completion
{
	NSParameterAssert(sql);
	
	//Execute query on worker queue
	[self.workerQueue addOperationWithBlock:^{
		
		if (!self.isConnected) {
			[self message:SQLClientNoConnectionError];
			[self executionFailure:completion];
			return;
		}
		
		if (self.isExecuting) {
			[self message:SQLClientPendingExecutionError];
			[self executionFailure:completion];
			return;
		}
		
		self.executing = YES;
		
		//Set query timeout
		dbsettime(self.timeout);
		
		//Prepare SQL statement
		_returnCode = dbcmd(_connection, [sql UTF8String]);
		if (_returnCode == FAIL) {
			[self executionFailure:completion];
			return;
		}
		
		//Execute SQL statement
		_returnCode = dbsqlexec(_connection);
		if (_returnCode == FAIL) {
			[self executionFailure:completion];
			return;
		}
		
		//Create array to contain the tables
		NSMutableArray* output = [NSMutableArray array];
		
		//Loop through each table metadata
		//dbresults() returns SUCCEED, FAIL or, NO_MORE_RESULTS.
		while ((_returnCode = dbresults(_connection)) != NO_MORE_RESULTS)
		{
			if (_returnCode == FAIL) {
				[self executionFailure:completion];
				return;
			}
			
			//Get number of columns
			_numColumns = dbnumcols(_connection);
			
			//No columns, skip to next table
			if (!_numColumns) {
				continue;
			}
			
			//Create array to contain the rows for this table
			NSMutableArray* table = [NSMutableArray array];
			
			//Allocate C-style array of COL structs
			_columns = calloc(_numColumns, sizeof(struct COLUMN));
			if (!_columns) {
				[self executionFailure:completion];
				return;
			}
			
			struct COLUMN* column;
			STATUS rowCode;
			
			//Bind the column info
			for (column = _columns; column - _columns < _numColumns; column++)
			{
				//Get column number
				int c = column - _columns + 1;
				
				//Get column metadata
				column->name = dbcolname(_connection, c);
				column->type = dbcoltype(_connection, c);
				column->size = dbcollen(_connection, c);
				
				//Set bind type based on column type
				int bindType = CHARBIND; //Default
				switch (column->type)
				{
					case SYBBIT:
					case SYBBITN:
					{
						bindType = BITBIND;
						break;
					}
					case SYBINT1:
					{
						bindType = TINYBIND;
						break;
					}
					case SYBINT2:
					{
						bindType = SMALLBIND;
						break;
					}
					case SYBINT4:
					case SYBINTN:
					{
						bindType = INTBIND;
						break;
					}
					case SYBINT8:
					{
						bindType = BIGINTBIND;
						break;
					}
					case SYBFLT8:
					case SYBFLTN:
					{
						bindType = FLT8BIND;
						break;
					}
					case SYBREAL:
					{
						bindType = REALBIND;
						break;
					}
					case SYBMONEY4:
					{
						bindType = SMALLMONEYBIND;
						break;
					}
					case SYBMONEY:
					case SYBMONEYN:
					{
						bindType = MONEYBIND;
						break;
					}
					case SYBDECIMAL:
					case SYBNUMERIC:
					{
						//Workaround for incorrect size
						bindType = CHARBIND;
						column->size += 23;
						break;
					}
					case SYBCHAR:
					case SYBVARCHAR:
					case SYBNVARCHAR:
					case SYBTEXT:
					case SYBNTEXT:
					{
						bindType = NTBSTRINGBIND;
						column->size = MIN(column->size, self.maxTextSize);
						break;
					}
					case SYBDATETIME:
					case SYBDATETIME4:
					case SYBDATETIMN:
					case SYBBIGDATETIME:
					case SYBBIGTIME:
					{
						bindType = DATETIMEBIND;
						break;
					}
					case SYBDATE:
					case SYBMSDATE:
					{
						bindType = DATEBIND;
						break;
					}
					case SYBTIME:
					case SYBMSTIME:
					{
						//Workaround for TIME data type. We have to increase the size and cast as string.
						column->size += 14;
						bindType = CHARBIND;
						break;
					}
					case SYBMSDATETIMEOFFSET:
					case SYBMSDATETIME2:
					{
						bindType = DATETIME2BIND;
						break;
					}
					case SYBVOID:
					case SYBIMAGE:
					case SYBBINARY:
					case SYBVARBINARY:
					case SYBUNIQUEIDENTIFIER:
					{
						bindType = BINARYBIND;
						break;
					}
				}
				
				//Create space for column data
				column->data = calloc(1, column->size);
				if (!column->data) {
					[self executionFailure:completion];
					return;
				}

				//Bind column data
				_returnCode = dbbind(_connection, c, bindType, column->size, column->data);
				if (_returnCode == FAIL) {
					[self executionFailure:completion];
					return;
				}
				
				//Bind null value into column status
				_returnCode = dbnullbind(_connection, c, &column->status);
				if (_returnCode == FAIL) {
					[self executionFailure:completion];
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
						NSMutableDictionary* row = [[NSMutableDictionary alloc] initWithCapacity:_numColumns];
						
						//Loop through each column and create an entry where dictionary[columnName] = columnValue
						for (column = _columns; column - _columns < _numColumns; column++)
						{
							//Default to null
							id value = [NSNull null];
							
							//If not null, update value with column data
							if (column->status != -1)
							{
								switch (column->type)
								{
									case SYBBIT: //0 or 1
									{
										BOOL _value;
										memcpy(&_value, column->data, sizeof _value);
										value = [NSNumber numberWithBool:_value];
										break;
									}
									case SYBINT1: //Whole numbers from 0 to 255
									case SYBINT2: //Whole numbers between -32,768 and 32,767
									{
										int16_t _value;
										memcpy(&_value, column->data, sizeof _value);
										value = [NSNumber numberWithShort:_value];
										break;
									}
									case SYBINT4: //Whole numbers between -2,147,483,648 and 2,147,483,647
									{
										int32_t _value;
										memcpy(&_value, column->data, sizeof _value);
										value = [NSNumber numberWithInt:_value];
										break;
									}
									case SYBINT8: //Whole numbers between -9,223,372,036,854,775,808 and 9,223,372,036,854,775,807
									{
										long long _value;
										memcpy(&_value, column->data, sizeof _value);
										value = [NSNumber numberWithLongLong:_value];
										break;
									}
									case SYBFLT8: //Floating precision number data from -1.79E+308 to 1.79E+308
									{
										double _value;
										memcpy(&_value, column->data, sizeof _value);
										value = [NSNumber numberWithDouble:_value];
										break;
									}
									case SYBREAL: //Floating precision number data from -3.40E+38 to 3.40E+38
									{
										float _value;
										memcpy(&_value, column->data, sizeof _value);
										value = [NSNumber numberWithFloat:_value];
										break;
									}
									case SYBDECIMAL: //Numbers from -10^38 +1 to 10^38 –1.
									case SYBNUMERIC:
									{
										NSString* _value = [[NSString alloc] initWithUTF8String:(char*)column->data];
										value = [NSDecimalNumber decimalNumberWithString:_value];
										break;
									}
									case SYBMONEY4: //Monetary data from -214,748.3648 to 214,748.3647
									{
										DBMONEY4 _value;
										memcpy(&_value, column->data, sizeof _value);
										NSNumber* number = @(_value.mny4);
										NSDecimalNumber* decimalNumber = [NSDecimalNumber decimalNumberWithString:[number description]];
										value = [decimalNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10000"]];
										break;
									}
									case SYBMONEY: //Monetary data from -922,337,203,685,477.5808 to 922,337,203,685,477.5807
									{
										BYTE* _value = calloc(20, sizeof(BYTE)); //Max string length is 20
										dbconvert(_connection, SYBMONEY, column->data, sizeof(SYBMONEY), SYBCHAR, _value, -1);
										value = [NSDecimalNumber decimalNumberWithString:[NSString stringWithUTF8String:(char*)_value]];
										free(_value);
										break;
									}
									case SYBDATETIME: //From 1/1/1753 00:00:00.000 to 12/31/9999 23:59:59.997 with an accuracy of 3.33 milliseconds
									case SYBDATETIMN:
									case SYBBIGDATETIME:
									case SYBBIGTIME:
									case SYBMSDATETIME2: //From 1/1/0001 00:00:00 to 12/31/9999 23:59:59.9999999 with an accuracy of 100 nanoseconds
									case SYBMSDATETIMEOFFSET: //The same as SYBMSDATETIME2 with the addition of a time zone offset
									{
										DBDATEREC2 _value;
										dbanydatecrack(_connection, &_value, column->type, column->data);
										value = [self dateWithYear:_value.dateyear month:_value.datemonth + 1 day:_value.datedmonth hour:_value.datehour minute:_value.dateminute second:_value.datesecond nanosecond:_value.datensecond timezone:_value.datetzone];
										break;
									}
									case SYBDATETIME4: //From January 1, 1900 00:00 to June 6, 2079 23:59 with an accuracy of 1 minute
									{
										DBDATEREC _value;
										dbdatecrack(_connection, &_value, (DBDATETIME*)column->data);
										value = [self dateWithYear:_value.dateyear month:_value.datemonth + 1 day:_value.datedmonth hour:_value.datehour minute:_value.dateminute second:_value.datesecond];
										break;
									}
									case SYBMSDATE: //From January 1, 0001 to December 31, 9999
									{
										DBDATEREC _value;
										dbdatecrack(_connection, &_value, (DBDATETIME*)column->data);
										value = [self dateWithYear:_value.dateyear month:_value.datemonth + 1 day:_value.datedmonth];
										break;
									}
									case SYBMSTIME: //00:00:00 to 23:59:59.9999999 with an accuracy of 100 nanoseconds
									{
										//Extract time components out of string since DBDATEREC conversion does not work
										NSString* string = [NSString stringWithUTF8String:(char*)column->data];
										value = [self dateWithTimeString:string];
										break;
									}
									case SYBCHAR:
									case SYBVARCHAR:
									case SYBNVARCHAR:
									case SYBTEXT:
									case SYBNTEXT:
									{
										value = [NSString stringWithUTF8String:(char*)column->data];
										break;
									}
									case SYBUNIQUEIDENTIFIER: //https://en.wikipedia.org/wiki/Globally_unique_identifier#Binary_encoding
									{
										//Convert GUID to UUID
										struct GUID _value;
										memcpy(&_value, column->data, sizeof _value);
										_value.data1 = NTOHL(_value.data1);
										_value.data2 = NTOHS(_value.data2);
										_value.data3 = NTOHS(_value.data3);
										value = [[NSUUID alloc] initWithUUIDBytes:(const unsigned char*)&_value];
										break;
									}
									case SYBVOID:
									case SYBIMAGE:
									case SYBBINARY:
									case SYBVARBINARY:
									{
										value = [NSData dataWithBytes:column->data length:column->size];
										break;
									}
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

			//Add immutable copy of table to output
			[output addObject:[table copy]];
			[self cleanupAfterTable];
		}
		
		//Success! Send an immutable copy of the results array
		[self executionSuccess:completion results:[output copy]];
	}];
}

- (void)disconnect
{
	[self.workerQueue addOperationWithBlock:^{
		[self cleanupAfterConnection];
		if (_connection) {
			dbclose(_connection);
			_connection = NULL;
		}
	}];
}

#pragma mark - FreeTDS Callbacks

//Handles message callback from FreeTDS library.
int msg_handler(DBPROCESS* dbproc, DBINT msgno, int msgstate, int severity, char* msgtext, char* srvname, char* procname, int line)
{
	//Can't call self from a C function, so need to access singleton
	SQLClient* self = [SQLClient sharedInstance];
	[self message:[NSString stringWithUTF8String:msgtext]];
	return INT_EXIT;
}

//Handles error callback from FreeTDS library.
int err_handler(DBPROCESS* dbproc, int severity, int dberr, int oserr, char* dberrstr, char* oserrstr)
{
	//Can't call self from a C function, so need to access singleton
	SQLClient* self = [SQLClient sharedInstance];
	[self error:[NSString stringWithUTF8String:dberrstr] code:dberr severity:severity];
	return INT_CANCEL;
}

//Posts a SQLClientMessageNotification notification
- (void)message:(NSString*)message
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[[NSNotificationCenter defaultCenter] postNotificationName:SQLClientMessageNotification object:nil userInfo:@{ SQLClientMessageKey:message }];
	}];
}

//Posts a SQLClientErrorNotification notification
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[[NSNotificationCenter defaultCenter] postNotificationName:SQLClientErrorNotification object:nil userInfo:@{
			SQLClientMessageKey:error,
			SQLClientCodeKey:@(code),
			SQLClientSeverityKey:@(severity)
		}];
	}];
}

#pragma mark - Cleanup

- (void)cleanupAfterTable
{
	if (_columns) {
		for (struct COLUMN* column = _columns; column - _columns < _numColumns; column++) {
			if (column) {
				free(column->data);
				column->data = NULL;
			}
		}
		free(_columns);
		_columns = NULL;
	}
}

- (void)cleanupAfterExecution
{
	[self cleanupAfterTable];
	if (_connection) {
		dbfreebuf(_connection);
	}
}

- (void)cleanupAfterConnection
{
	[self cleanupAfterExecution];
	if (_login) {
		dbloginfree(_login);
		_login = NULL;
	}
	free(_password);
	_password = NULL;
}

#pragma mark - Private

//Invokes connection completion handler on callback queue with success = NO
- (void)connectionFailure:(void (^)(BOOL success))completion
{
	[self cleanupAfterConnection];
	[self.callbackQueue addOperationWithBlock:^{
		if (completion) {
			completion(NO);
		}
	}];
}

//Invokes connection completion handler on callback queue with success = [self connected]
- (void)connectionSuccess:(void (^)(BOOL success))completion
{
	[self cleanupAfterConnection];
	[self.callbackQueue addOperationWithBlock:^{
		if (completion) {
			completion([self isConnected]);
		}
	}];
}

//Invokes execution completion handler on callback queue with results = nil
- (void)executionFailure:(void (^)(NSArray* results))completion
{
	self.executing = NO;
	[self cleanupAfterExecution];
	[self.callbackQueue addOperationWithBlock:^{
		if (completion) {
			completion(nil);
		}
	}];
}

//Invokes execution completion handler on callback queue with results array
- (void)executionSuccess:(void (^)(NSArray* results))completion results:(NSArray*)results
{
	self.executing = NO;
	[self cleanupAfterExecution];
	[self.callbackQueue addOperationWithBlock:^{
		if (completion) {
			completion(results);
		}
	}];
}

#pragma mark - Date

- (NSDate*)referenceDate
{
	return [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0];
}

- (NSDate*)dateWithYear:(int)year month:(int)month day:(int)day
{
	return [self dateWithYear:year month:month day:day hour:0 minute:0 second:0];
}

- (NSDate*)dateWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second
{
	return [self dateWithYear:year month:month day:day hour:hour minute:minute second:second nanosecond:0];
}

- (NSDate*)dateWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second nanosecond:(int)nanosecond
{
	return [self dateWithYear:year month:month day:day hour:hour minute:minute second:second nanosecond:0 timezone:0];
}

- (NSDate*)dateWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second nanosecond:(int)nanosecond timezone:(int)timezone
{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
	dateComponents.year = year;
	dateComponents.month = month;
	dateComponents.day = day;
	dateComponents.hour = hour;
	dateComponents.minute = minute;
	dateComponents.second = second;
	dateComponents.nanosecond = nanosecond;
	dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:timezone * 60];
	return [calendar dateFromComponents:dateComponents];
}

- (NSDate*)dateWithTimeString:(NSString*)string
{
	if (string.length < 30) {
		return nil;
	}
	
	NSString* time = [string substringFromIndex:string.length - 18];
	int hour = [[time substringWithRange:NSMakeRange(0, 2)] integerValue];
	int minute = [[time substringWithRange:NSMakeRange(3, 2)] integerValue];
	int second = [[time substringWithRange:NSMakeRange(6, 2)] integerValue];
	int nanosecond = [[time substringWithRange:NSMakeRange(9, 7)] integerValue];
	NSString* meridian = [time substringWithRange:NSMakeRange(16, 2)];
	
	if ([meridian isEqualToString:@"AM"]) {
		if (hour == 12) {
			hour = 0;
		}
	} else {
		if (hour < 12) {
			hour += 12;
		}
	}
	
	return [self dateWithYear:1900 month:1 day:1 hour:hour minute:minute second:second nanosecond:nanosecond * 100 timezone:0];
}

@end
