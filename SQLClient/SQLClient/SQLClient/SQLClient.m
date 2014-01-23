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
NSString* const SQLClientDefaultCharset = @"UTF-8";
NSString* const SQLClientWorkerQueueName = @"com.martinrybak.sqlclient";
NSString* const SQLClientDelegateError = @"Delegate must be set to an NSObject that implements the SQLClientDelegate protocol";
NSString* const SQLClientRowIgnoreMessage = @"Ignoring unknown row type";

struct COL
{
	char* name;
	char* buffer;
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
	LOGINREC* login;
	DBPROCESS* connection;
	char* _password;
}

#pragma mark - NSObject

//Initializes the FreeTDS library and sets callback handlers
- (id)init
{
    if (self = [super init])
    {
        //Initialize the FreeTDS library
        if (dbinit() == FAIL)
			return nil;
		
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

+ (id)sharedInstance
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
		if ((login = dblogin()) == FAIL)
			return [self connectionFailure:completion];
		
		//Populate login struct
		DBSETLUSER(login, [self.username UTF8String]);
		DBSETLPWD(login, _password);
		DBSETLHOST(login, [self.host UTF8String]);
		DBSETLCHARSET(login, [self.charset UTF8String]);
		
		//Connect to database server
		if ((connection = dbopen(login, [self.host UTF8String])) == NULL)
			return [self connectionFailure:completion];
		
		//Switch to database
		if (dbuse(connection, [self.database UTF8String]) == FAIL)
			return [self connectionFailure:completion];
	
		//Success!
		[self connectionSuccess:completion];
	}];
}

- (BOOL)connected
{
	return !dbdead(connection);
}

// TODO: how to get number of records changed during update or delete
// TODO: how to handle SQL stored procedure output parameters
- (void)execute:(NSString*)sql completion:(void (^)(NSArray* results))completion
{
	//Execute query on worker queue
	[self.workerQueue addOperationWithBlock:^{
			
		//Prepare SQL statement
		dbcmd(connection, [sql UTF8String]);
		
		//Execute SQL statement
		if (dbsqlexec(connection) == FAIL)
			return [self executionFailure:completion];
		
		//Create array to contain the tables
		NSMutableArray* output = [[NSMutableArray alloc] init];
		
		struct COL* columns;
		struct COL* pcol;
		int erc;
		
		//Loop through each table
		while ((erc = dbresults(connection)) != NO_MORE_RESULTS)
		{
			int ncols;
			int row_code;
						
			//Create array to contain the rows for this table
			NSMutableArray* table = [[NSMutableArray alloc] init];
			
			//Get number of columns
			ncols = dbnumcols(connection);
			
			//Allocate C-style array of COL structs
			if ((columns = calloc(ncols, sizeof(struct COL))) == NULL)
				return [self executionFailure:completion];
			
			//Bind the column info
			for (pcol = columns; pcol - columns < ncols; pcol++)
			{
				//Get column number
				int c = pcol - columns + 1;
				
				//Get column metadata
				pcol->name = dbcolname(connection, c);
				pcol->type = dbcoltype(connection, c);
				pcol->size = dbcollen(connection, c);
				
				//If the column is [VAR]CHAR, we want the column's defined size, otherwise we want
				//its maximum size when represented as a string, which FreeTDS's dbwillconvert()
				//returns (for fixed-length datatypes).
				if (pcol->type != SYBCHAR)
					pcol->size = dbwillconvert(pcol->type, SYBCHAR);
				
				//Allocate memory in the current pcol struct for a buffer
				if ((pcol->buffer = calloc(1, pcol->size + 1)) == NULL)
					return [self executionFailure:completion];
				
				//Bind column name
				erc = dbbind(connection, c, NTBSTRINGBIND, pcol->size + 1, (BYTE*)pcol->buffer);
				if (erc == FAIL)
					return [self executionFailure:completion];
				
				//Bind column status
				erc = dbnullbind(connection, c, &pcol->status);
				if (erc == FAIL)
					return [self executionFailure:completion];
				
				//printf("%s is type %d with value %s\n", pcol->name, pcol->type, pcol->buffer);
			}
			
			//printf("\n");
			
			//Loop through each row
			while ((row_code = dbnextrow(connection)) != NO_MORE_ROWS)
			{
				//Check row type
				switch (row_code)
				{
					//Regular row
					case REG_ROW:
					{
						//Create a new dictionary to contain the column names and vaues
						NSMutableDictionary* row = [[NSMutableDictionary alloc] initWithCapacity:ncols];
						
						//Loop through each column and create an entry where dictionary[columnName] = columnValue
						for (pcol = columns; pcol - columns < ncols; pcol++)
						{
							NSString* column = [NSString stringWithUTF8String:pcol->name];
							id value = [NSString stringWithUTF8String:pcol->buffer] ?: [NSNull null];
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
						return [self executionFailure:completion];
					//Error
					case FAIL:
						return [self executionFailure:completion];
					default:
						[self message:SQLClientRowIgnoreMessage];
				}
			}
			
			//Clean up
			for (pcol = columns; pcol - columns < ncols; pcol++)
				free(pcol->buffer);
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
    dbclose(connection);
}

#pragma mark - Private

//Invokes connection completion handler on callback queue with success = NO
- (void)connectionFailure:(void (^)(BOOL success))completion
{
    [self.callbackQueue addOperationWithBlock:^{
        if (completion)
            completion(NO);
    }];
    
    //Cleanup
    dbloginfree(login);
	free(_password);
}

//Invokes connection completion handler on callback queue with success = [self connected]
- (void)connectionSuccess:(void (^)(BOOL success))completion
{
    [self.callbackQueue addOperationWithBlock:^{
        if (completion)
            completion([self connected]);
    }];
    
    //Cleanup
    dbloginfree(login);
	free(_password);
}

//Invokes execution completion handler on callback queue with results = nil
- (void)executionFailure:(void (^)(NSArray* results))completion
{
    [self.callbackQueue addOperationWithBlock:^{
        if (completion)
            completion(nil);
    }];
    
    //Clean up
    dbfreebuf(connection);
}

//Invokes execution completion handler on callback queue with results array
- (void)executionSuccess:(void (^)(NSArray* results))completion results:(NSArray*)results
{
    [self.callbackQueue addOperationWithBlock:^{
        if (completion)
            completion(results);
    }];
    
    //Clean up
    dbfreebuf(connection);
}

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
		if ([self.delegate respondsToSelector:@selector(message:)])
			[self.delegate message:message];
	}];
}

//Forwards an error message to the delegate on the callback queue.
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
	if (!self.delegate || ![self.delegate conformsToProtocol:@protocol(SQLClientDelegate)])
		[NSException raise:SQLClientDelegateError format:nil];
	
	//Invoke delegate on callback queue
	[self.callbackQueue addOperationWithBlock:^{
		[self.delegate error:error code:code severity:severity];
	}];
}

@end
