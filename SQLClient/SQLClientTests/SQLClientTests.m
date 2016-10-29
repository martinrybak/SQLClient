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

#pragma mark - Numbers

- (void)testBit
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Bit FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Bit"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Bit"], @(YES));
		XCTAssertEqualObjects(results[0][2][@"Bit"], @(NO));
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

- (void)testFloat
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Float FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Float"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Float"], @(-1.79e+308));
		XCTAssertEqualObjects(results[0][2][@"Float"], @(1.79e+308));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testReal
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Real FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Real"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Real"], [NSNumber numberWithFloat:-3.4e+38]);
		XCTAssertEqualObjects(results[0][2][@"Real"], [NSNumber numberWithFloat:3.4e+38]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

/* TODO:
 decimal
 numeric
 */

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

#pragma mark - Dates

- (void)testSmallDateTime
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT SmallDateTime FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"SmallDateTime"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"SmallDateTime"], [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0]);
		XCTAssertEqualObjects(results[0][2][@"SmallDateTime"], [self dateWithYear:2079 month:6 day:6 hour:23 minute:59 second:0 nanosecond:0 timezone:0]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testDateTime
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT DateTime FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"DateTime"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"DateTime"], [self dateWithYear:1753 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0]);
		XCTAssertEqualObjects(results[0][2][@"DateTime"], [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:997000000 timezone:0]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

#pragma mark TDS 7.3

//If these test fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateTime2
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT DateTime2 FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"DateTime2"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"DateTime2"], [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0]);
		XCTAssertEqualObjects(results[0][2][@"DateTime2"], [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testDateTimeOffset
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT DateTimeOffset FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"DateTimeOffset"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"DateTimeOffset"], [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:-840]);
		XCTAssertEqualObjects(results[0][2][@"DateTimeOffset"], [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:840]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testDate
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Date FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Date"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Date"], [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0]);
		XCTAssertEqualObjects(results[0][2][@"Date"], [self dateWithYear:9999 month:12 day:31 hour:0 minute:0 second:0 nanosecond:0 timezone:0]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testTime
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Time FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Time"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Time"], [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0]);
		XCTAssertEqualObjects(results[0][2][@"Time"], [self dateWithYear:1900 month:1 day:1 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0]);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

#pragma mark - Text

- (void)testChar
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Char10 FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Char10"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Char10"], @"a");
		XCTAssertEqualObjects(results[0][2][@"Char10"], @"abcdefghi");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testVarChar
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT VarCharMax FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"VarCharMax"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"VarCharMax"], @"a");
		XCTAssertEqual([results[0][2][@"VarCharMax"] length], [SQLClient sharedInstance].maxTextSize - 1);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testText
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Text FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Text"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Text"], @"a");
		XCTAssertEqual([results[0][2][@"Text"] length], [SQLClient sharedInstance].maxTextSize - 1);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testXml
{
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:@"SELECT Xml FROM Test" completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Xml"], [NSNull null]);
		XCTAssertEqualObjects(results[0][1][@"Xml"], @"<a/>");
		XCTAssertEqual([results[0][2][@"Xml"] length], [SQLClient sharedInstance].maxTextSize - 1);
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

- (NSString*)stringWithLength:(NSUInteger)length
{
	NSMutableString* output = [NSMutableString string];
	for (NSUInteger i = 0; i < length; i++) {
		//32-127 == printable ASCII values
		char character = arc4random_uniform(95) + 32;
		[output appendString:[NSString stringWithFormat:@"%c", character]];
	}
	return [output copy];
}

@end
