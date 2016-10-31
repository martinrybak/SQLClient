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

#pragma mark - Bit

- (void)testBitWithNull
{
	id value = [NSNull null];
	[self testServerType:@"BIT" serverValue:nil expectedValue:value];
}

- (void)testBitWithTrue
{
	id value = @(YES);
	[self testServerType:@"BIT" serverValue:value expectedValue:value];
}

- (void)testBitWithFalse
{
	id value = @(YES);
	[self testServerType:@"BIT" serverValue:value expectedValue:value];
}

#pragma mark - Tiny Int

- (void)testTinyIntWithNull
{
	id value = [NSNull null];
	[self testServerType:@"TINYINT" serverValue:nil expectedValue:value];
}

- (void)testTinyIntWithMinimum
{
	id value = @(0);
	[self testServerType:@"TINYINT" serverValue:value expectedValue:value];
}

- (void)testTinyIntWithMaximum
{
	id value = @(UCHAR_MAX);
	[self testServerType:@"TINYINT" serverValue:value expectedValue:value];
}

#pragma mark - Small Int

- (void)testSmallIntWithNull
{
	id value = [NSNull null];
	[self testServerType:@"SMALLINT" serverValue:nil expectedValue:value];
}

- (void)testSmallIntWithMinimum
{
	id value = @(SHRT_MIN);
	[self testServerType:@"SMALLINT" serverValue:value expectedValue:value];
}

- (void)testSmallIntWithMaximum
{
	id value = @(SHRT_MAX);
	[self testServerType:@"SMALLINT" serverValue:value expectedValue:value];
}

#pragma mark - Int

- (void)testIntWithNull
{
	id value = [NSNull null];
	[self testServerType:@"INT" serverValue:nil expectedValue:value];
}

- (void)testIntWithMinimum
{
	id value = @(SHRT_MIN);
	[self testServerType:@"INT" serverValue:value expectedValue:value];
}

- (void)testIntWithMaximum
{
	id value = @(SHRT_MAX);
	[self testServerType:@"INT" serverValue:value expectedValue:value];
}

#pragma mark - Big Int

- (void)testBigIntWithNull
{
	id value = [NSNull null];
	[self testServerType:@"BIGINT" serverValue:nil expectedValue:value];
}

- (void)testBigIntWithMinimum
{
	id value = @(LLONG_MIN);
	[self testServerType:@"BIGINT" serverValue:value expectedValue:value];
}

- (void)testBigIntWithMaximum
{
	id value = @(LLONG_MAX);
	[self testServerType:@"BIGINT" serverValue:value expectedValue:value];
}

#pragma mark - Float

- (void)testFloatWithNull
{
	id value = [NSNull null];
	[self testServerType:@"FLOAT" serverValue:nil expectedValue:value];
}

- (void)testFloatWithMinimum
{
	id value = @(-1.79e+308);
	[self testServerType:@"FLOAT" serverValue:value expectedValue:value];
}

- (void)testFloatWithMaximum
{
	id value = @(1.79e+308);
	[self testServerType:@"FLOAT" serverValue:value expectedValue:value];
}

#pragma mark - Real

- (void)testRealWithNull
{
	id value = [NSNull null];
	[self testServerType:@"REAL" serverValue:nil expectedValue:value];
}

- (void)testRealWithMinimum
{
	id value = [NSNumber numberWithFloat:-3.4e+38];
	[self testServerType:@"REAL" serverValue:value expectedValue:value];
}

- (void)testRealWithMaximum
{
	id value = [NSNumber numberWithFloat:3.4e+38];
	[self testServerType:@"REAL" serverValue:value expectedValue:value];
}

#pragma mark - Decimal

- (void)testDecimal
{
	
}

#pragma mark - Numeric

- (void)testNumeric
{
	
}

#pragma mark - Small Money

- (void)testSmallMoneyWithNull
{
	id value = [NSNull null];
	[self testServerType:@"SMALLMONEY" serverValue:nil expectedValue:value];
}

- (void)testSmallMoneyWithMinimum
{
	id value = [NSDecimalNumber decimalNumberWithString:@"-214748.3648"];
	[self testServerType:@"SMALLMONEY" serverValue:value expectedValue:value];
}

- (void)testSmallMoneyWithMaximum
{
	id value = [NSDecimalNumber decimalNumberWithString:@"214748.3647"];
	[self testServerType:@"SMALLMONEY" serverValue:value expectedValue:value];
}

#pragma mark - Money

- (void)testMoneyWithNull
{
	id value = [NSNull null];
	[self testServerType:@"MONEY" serverValue:nil expectedValue:value];
}

- (void)testMoneyWithMinimum
{
	//TODO: fix last 2 digits, i.e. -922337203685477.5808 returns -922337203685477.58
	id value = [NSDecimalNumber decimalNumberWithString:@"-922337203685477.58"];
	[self testServerType:@"MONEY" serverValue:value expectedValue:value];
}

- (void)testMoneyWithMaximum
{
	//TODO: fix last 2 digits, i.e. 922337203685477.5807 returns 922337203685477.58
	id value = [NSDecimalNumber decimalNumberWithString:@"922337203685477.58"];
	[self testServerType:@"MONEY" serverValue:value expectedValue:value];
}

#pragma mark - Small DateTime

- (void)testSmallDateTimeWithNull
{
	id value = [NSNull null];
	[self testServerType:@"SMALLDATETIME" serverValue:nil expectedValue:value];
}

- (void)testSmallDateTimeWithMinimum
{
	id value = @"01-01-1900 00:00:00";
	id expectedValue = [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testServerType:@"SMALLDATETIME" serverValue:value expectedValue:expectedValue];
}

- (void)testSmallDateTimeWithMaximum
{
	id value = @"06-06-2079 23:59:00";
	id expectedValue = [self dateWithYear:2079 month:6 day:6 hour:23 minute:59 second:0 nanosecond:0 timezone:0];
	[self testServerType:@"SMALLDATETIME" serverValue:value expectedValue:expectedValue];
}

#pragma mark - DateTime

- (void)testDateTimeWithNull
{
	id value = [NSNull null];
	[self testServerType:@"DATETIME" serverValue:nil expectedValue:value];
}

- (void)testDateTimeWithMinimum
{
	id value = @"01-01-1753 00:00:00:000";
	id expectedValue = [self dateWithYear:1753 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testServerType:@"DATETIME" serverValue:value expectedValue:expectedValue];
}

- (void)testDateTimeWithMaximum
{
	id value = @"12-31-9999 23:59:59:997";
	id expectedValue = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:997000000 timezone:0];
	[self testServerType:@"DATETIME" serverValue:value expectedValue:expectedValue];
}

#pragma mark - DateTime2

//If these test fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateTime2WithNull
{
	id value = [NSNull null];
	[self testServerType:@"DATETIME2" serverValue:nil expectedValue:value];
}

- (void)testDateTime2WithMinimum
{
	id value = @"01-01-0001 00:00:00.0000000";
	id expectedValue = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testServerType:@"DATETIME2" serverValue:value expectedValue:expectedValue];
}

- (void)testDateTime2WithMaximum
{
	id value = @"12-31-9999 23:59:59.9999999";
	id expectedValue = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0];
	[self testServerType:@"DATETIME2" serverValue:value expectedValue:expectedValue];
}

#pragma mark - DateTimeOffset

//If these test fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateTimeOffsetWithNull
{
	id value = [NSNull null];
	[self testServerType:@"DATETIMEOFFSET" serverValue:nil expectedValue:value];
}

- (void)testDateTimeOffsetWithMinimum
{
	id value = @"01-01-0001 00:00:00.0000000 -14:00";
	id expectedValue = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:-840];
	[self testServerType:@"DATETIMEOFFSET" serverValue:value expectedValue:expectedValue];
}

- (void)testDateTimeOffsetWithMaximum
{
	id value = @"12-31-9999 23:59:59.9999999 +14:00";
	id expectedValue = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:840];
	[self testServerType:@"DATETIMEOFFSET" serverValue:value expectedValue:expectedValue];
}

#pragma mark - Date

//If these test fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateWithNull
{
	id value = [NSNull null];
	[self testServerType:@"DATE" serverValue:nil expectedValue:value];
}

- (void)testDateWithMinimum
{
	id value = @"01-01-0001";
	id expectedValue = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testServerType:@"DATE" serverValue:value expectedValue:expectedValue];
}

- (void)testDateWithMaximum
{
	id value = @"12-31-9999";
	id expectedValue = [self dateWithYear:9999 month:12 day:31 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testServerType:@"DATE" serverValue:value expectedValue:expectedValue];
}

#pragma mark - Time

- (void)testTimeWithNull
{
	id value = [NSNull null];
	[self testServerType:@"TIME" serverValue:nil expectedValue:value];
}

- (void)testTimeWithMinimum
{
	id value = @"00:00:00.0000000";
	id expectedValue = [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testServerType:@"TIME" serverValue:value expectedValue:expectedValue];
}

- (void)testTimeWithMaximum
{
	id value = @"23:59:59.9999999";
	id expectedValue = [self dateWithYear:1900 month:1 day:1 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0];
	[self testServerType:@"TIME" serverValue:value expectedValue:expectedValue];
}

#pragma mark - Char

- (void)testCharWithNull
{
	id value = [NSNull null];
	[self testServerType:@"CHAR(1)" serverValue:nil expectedValue:value];
}

- (void)testCharWithMinimum
{
	//33 = minimum ASCII value (32 doesn't work)
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testServerType:@"CHAR(1)" serverValue:value expectedValue:value];
}

- (void)testCharWithMaximum
{
	//127 = maximum printable ASCII value
	id value = [NSString stringWithFormat:@"%c", 127];
	[self testServerType:@"CHAR(1)" serverValue:value expectedValue:value];
}

#pragma mark - VarChar(Max)

- (void)testVarCharMaxWithNull
{
	id value = [NSNull null];
	[self testServerType:@"VARCHAR(MAX)" serverValue:nil expectedValue:value];
}

- (void)testVarCharMaxWithMinimum
{
	//33 = minimum ASCII value (32 doesn't work)
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testServerType:@"VARCHAR(MAX)" serverValue:value expectedValue:value];
}

- (void)testVarCharMaxWithMaximum
{
	id value = [self stringWithLength:[SQLClient sharedInstance].maxTextSize + 1];
	id expectedValue = [value substringToIndex:[SQLClient sharedInstance].maxTextSize - 1];
	[self testServerType:@"VARCHAR(MAX)" serverValue:value expectedValue:expectedValue];
}

#pragma mark - Text

- (void)testTextWithNull
{
	id value = [NSNull null];
	[self testServerType:@"TEXT" serverValue:nil expectedValue:value];
}

- (void)testTextWithMinimum
{
	//33 = minimum ASCII value (32 doesn't work)
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testServerType:@"TEXT" serverValue:value expectedValue:value];
}

- (void)testTextWithMaximum
{
	id value = [self stringWithLength:[SQLClient sharedInstance].maxTextSize + 1];
	id expectedValue = [value substringToIndex:[SQLClient sharedInstance].maxTextSize - 1];
	[self testServerType:@"TEXT" serverValue:value expectedValue:expectedValue];
}

#pragma mark - Xml

- (void)testXml
{
//	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//	[self execute:@"SELECT Xml FROM Test" completion:^(NSArray* results) {
//		XCTAssertEqualObjects(results[0][0][@"Xml"], [NSNull null]);
//		XCTAssertEqualObjects(results[0][1][@"Xml"], @"<a/>");
//		XCTAssertEqual([results[0][2][@"Xml"] length], [SQLClient sharedInstance].maxTextSize - 1);
//		[expectation fulfill];
//	}];
//	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

#pragma mar - Uniqueidentifier

- (void)testUniqueIdentifierWithNull
{
	id value = [NSNull null];
	[self testServerType:@"UNIQUEIDENTIFIER" serverValue:nil expectedValue:value];
}

- (void)testUniqueIdentifierWithValue
{
	id expectedValue = [NSUUID UUID];
	id value = [expectedValue UUIDString];
	[self testServerType:@"UNIQUEIDENTIFIER" serverValue:value expectedValue:expectedValue];
}

#pragma mark - Binary

- (void)testBinary
{
	
}

- (void)testImage
{
	
}

#pragma mark - Private

- (void)testServerType:(NSString*)serverType serverValue:(id)serverValue expectedValue:(id)expectedValue
{
	NSString* sql = [NSString stringWithFormat:@"SELECT CAST(NULL AS %@) AS Value", serverType];
	if (serverValue) {
		sql = [NSString stringWithFormat:@"SELECT CAST('%@' AS %@) AS Value", serverValue, serverType];
	}

	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Value"], expectedValue);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

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
		//65-122 == alphanumeric ASCII values
		char character = arc4random_uniform(65) + 57;
		[output appendString:[NSString stringWithFormat:@"%c", character]];
	}
	//Sanitize
	return [output stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

@end
