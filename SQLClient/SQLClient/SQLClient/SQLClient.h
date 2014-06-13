//
//  SQLClient.h
//  SQLClient
//
//  Created by Martin Rybak on 10/4/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SQLClientDelegate <NSObject>

/**
 *  Required delegate method to receive error notifications
 *
 *  @param error    Error text
 *  @param code     FreeTDS error code
 *  @param severity FreeTDS error severity
 */
- (void)error:(NSString*)error code:(int)code severity:(int)severity;

@optional

/**
 *  Optional delegate method to receive message notifications
 *
 *  @param message Message text
 */
- (void)message:(NSString*)message;

@end

/**
 *  Native SQL Server client for iOS. An Objective-C wrapper around the open-source FreeTDS library.
 */
@interface SQLClient : NSObject

/**
 *  Connection timeout, in seconds. Default is 5. Override before calling connect:
 */
@property (nonatomic, assign) int timeout;

/**
 *  The database server, i.e. server, server:port, or server\instance (be sure to escape the backslash)
 */
@property (nonatomic, copy, readonly) NSString* host;

/**
 *  The database username
 */
@property (nonatomic, copy, readonly) NSString* username;

/**
 *  The database name to use
 */
@property (nonatomic, copy, readonly) NSString* database;

/**
 *  The delegate to receive error: and message: callbacks
 */
@property (nonatomic, weak) NSObject<SQLClientDelegate>* delegate;

/**
 *  The queue for database operations. By default, uses a new queue called 'com.martinrybak.sqlclient' created upon singleon intialization. Can be overridden.
 */
@property (nonatomic, strong) NSOperationQueue* workerQueue;

/**
 *  The queue for block callbacks. By default, uses the current queue upon singleton initialization. Can be overridden.
 */
@property (nonatomic, weak) NSOperationQueue* callbackQueue;

/**
 *  The character set to use for converting the UCS-2 server results. Default is UTF-8.
 Can be overridden to any charset supported by the iconv library.
 To list all supported iconv character sets, open a Terminal window and enter:
 $ iconv --list
 */
@property (nonatomic, copy) NSString* charset;

/**
 *  Returns an initialized SQLClient instance as a singleton
 *
 *  @return Shared SQLClient object
 */
+ (instancetype)sharedInstance;

/**
 *  Connects to a SQL database server
 *
 *  @param host     Required. The database server, i.e. server, server:port, or server\instance (be sure to escape the backslash)
 *  @param username Required. The database username
 *  @param password Required. The database password
 *  @param database Required. The database name
 *  @param delegate Required. An NSObject that implements the SQLClientDelegate protocol for receiving error messages
 *  @param completion Block to be executed upon method successful connection
 */
- (void)connect:(NSString*)host
       username:(NSString*)username
       password:(NSString*)password
       database:(NSString*)database
     completion:(void (^)(BOOL success))completion;

/**
 *  Indicates whether the database is currently connected
 */
- (BOOL)connected;

/**
 *  Executes a SQL statement. Results of queries will be passed to the completion handler. Inserts, updates, and deletes do not return results.
 *
 *  @param sql Required. A SQL statement
 *  @param completion Block to be executed upon method completion. Accepts an NSArray of tables. Each table is an NSArray of rows. Each row is an NSDictionary of columns where key = name and object = value as an NSString.
 */
- (void)execute:(NSString*)sql completion:(void (^)(NSArray* results))completion;

/**
 *  Disconnects from database server
 */
- (void)disconnect;

@end
