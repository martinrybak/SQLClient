//
//  SQLClientTests.m
//  SQLClientTests
//
//  Created by Martin Rybak on 10/15/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQLClient.h"

@interface SQLClientTests : XCTestCase

@end

@implementation SQLClientTests

- (void)testBit
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Bit FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Bit"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Bit"], @(1));
		XCTAssertEqualObjects(results[0][2][@"Bit"], @(0));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testTinyInt
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT TinyInt FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"TinyInt"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"TinyInt"], @(0));
		XCTAssertEqualObjects(results[0][2][@"TinyInt"], @(255));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testSmallInt
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT SmallInt FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"SmallInt"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"SmallInt"], @(-32768));
		XCTAssertEqualObjects(results[0][2][@"SmallInt"], @(32767));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testInt
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Int FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Int"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Int"], @(-2147483648));
		XCTAssertEqualObjects(results[0][2][@"Int"], @(2147483647));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testBigInt
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT BigInt FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"BigInt"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"BigInt"], @((signed long long)-9223372036854775808));
		XCTAssertEqualObjects(results[0][2][@"BigInt"], @((signed long long)9223372036854775807));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

#pragma mark - Private

- (void)execute:(NSString*)sql completion:(void (^)(NSArray* results))completion
{
	NSDictionary* environment = [[NSProcessInfo processInfo] environment];
	SQLClient* client = [SQLClient sharedInstance];
	
	//Create environment variables in the Test Debug Scheme
	NSString* host = environment[@"HOST"];
	NSString* username = environment[@"USERNAME"];
	NSString* password = environment[@"PASSWORD"];
	NSString* database = environment[@"DATABASE"];
	
	NSParameterAssert(host);
	NSParameterAssert(username);
	NSParameterAssert(password);
	
	[client connect:host username:username password:password database:database completion:^(BOOL success) {
		[client execute:sql completion:^(NSArray* results) {
			[client disconnect];
			if (completion) {
				completion(results);
			}
		}];
	}];
}

@end
