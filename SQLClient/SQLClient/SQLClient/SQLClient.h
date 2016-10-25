//
//  SQLClient.h
//  SQLClient
//
//  Created by Martin Rybak on 10/4/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const SQLClientMessageNotification;
extern NSString* const SQLClientErrorNotification;
extern NSString* const SQLClientMessageKey;
extern NSString* const SQLClientCodeKey;
extern NSString* const SQLClientSeverityKey;

/**
 *  Native SQL Server client for iOS. An Objective-C wrapper around the open-source FreeTDS library.
 */
@interface SQLClient : NSObject

/**
 *  Connection timeout, in seconds. Default is 5. Set before calling connect.
 */
@property (nonatomic, assign) int timeout;

/**
 *  The character set to use for converting the UCS-2 server results. Default is UTF-8.
 *  Set before calling connect. Can be set to any charset supported by the iconv library.
 *  To list all supported iconv character sets, open a Terminal window and enter:
 $  iconv --list
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
 *  Indicates whether the database is currently connected.
 */
- (BOOL)isConnected;

/**
 *  Indicates whether the database is executing a command.
 */
- (BOOL)isExecuting;

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
