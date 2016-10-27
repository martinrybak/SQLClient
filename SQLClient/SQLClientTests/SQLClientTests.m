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
		XCTAssertEqualObjects(results[0][2][@"TinyInt"], @(UCHAR_MAX));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testSmallInt
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT SmallInt FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"SmallInt"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"SmallInt"], @(SHRT_MIN));
		XCTAssertEqualObjects(results[0][2][@"SmallInt"], @(SHRT_MAX));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testInt
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Int FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Int"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Int"], @(INT_MIN));
		XCTAssertEqualObjects(results[0][2][@"Int"], @(INT_MAX));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testBigInt
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT BigInt FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"BigInt"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"BigInt"], @(LLONG_MIN));
		XCTAssertEqualObjects(results[0][2][@"BigInt"], @(LLONG_MAX));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testSmallMoney
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT SmallMoney FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"SmallMoney"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"SmallMoney"], [NSDecimalNumber decimalNumberWithString:@"-214748.3648"]);
		XCTAssertEqualObjects(results[0][2][@"SmallMoney"], [NSDecimalNumber decimalNumberWithString:@"214748.3647"]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testMoney
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Money FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Money"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Money"], [NSDecimalNumber decimalNumberWithString:@"-922337203685477.58"]);
		XCTAssertEqualObjects(results[0][2][@"Money"], [NSDecimalNumber decimalNumberWithString:@"922337203685477.58"]);
		//TODO: fix last 2 digits truncated
		//XCTAssertEqualObjects(results[0][1][@"Money"], [NSDecimalNumber decimalNumberWithString:@"-922337203685477.5808"]);
		//XCTAssertEqualObjects(results[0][2][@"Money"], [NSDecimalNumber decimalNumberWithString:@"922337203685477.5807"]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

#pragma mark - Private

- (void)execute:(NSString*)sql completion:(void (^)(NSArray* results))completion
{
	//Environment variables from the Test Debug Scheme
	NSDictionary* environment = [[NSProcessInfo processInfo] environment];
	NSString* host = environment[@"HOST"];
	NSString* username = environment[@"USERNAME"];
	NSString* password = environment[@"PASSWORD"];
	NSString* database = environment[@"DATABASE"];
	
	NSParameterAssert(host);
	NSParameterAssert(username);
	NSParameterAssert(password);
	
	SQLClient* client = [SQLClient sharedInstance];
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
