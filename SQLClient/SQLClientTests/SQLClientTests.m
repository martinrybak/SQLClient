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
	[self testCast:@"BIT" input:nil output:value];
}

- (void)testBitWithTrue
{
	id value = @(YES);
	[self testCast:@"BIT" input:value output:value];
}

- (void)testBitWithFalse
{
	id value = @(YES);
	[self testCast:@"BIT" input:value output:value];
}

#pragma mark - Tiny Int

- (void)testTinyIntWithNull
{
	id value = [NSNull null];
	[self testCast:@"TINYINT" input:nil output:value];
}

- (void)testTinyIntWithMinimum
{
	id value = @(0);
	[self testCast:@"TINYINT" input:value output:value];
}

- (void)testTinyIntWithMaximum
{
	id value = @(UCHAR_MAX);
	[self testCast:@"TINYINT" input:value output:value];
}

#pragma mark - Small Int

- (void)testSmallIntWithNull
{
	id value = [NSNull null];
	[self testCast:@"SMALLINT" input:nil output:value];
}

- (void)testSmallIntWithMinimum
{
	id value = @(SHRT_MIN);
	[self testCast:@"SMALLINT" input:value output:value];
}

- (void)testSmallIntWithMaximum
{
	id value = @(SHRT_MAX);
	[self testCast:@"SMALLINT" input:value output:value];
}

#pragma mark - Int

- (void)testIntWithNull
{
	id value = [NSNull null];
	[self testCast:@"INT" input:nil output:value];
}

- (void)testIntWithMinimum
{
	id value = @(SHRT_MIN);
	[self testCast:@"INT" input:value output:value];
}

- (void)testIntWithMaximum
{
	id value = @(SHRT_MAX);
	[self testCast:@"INT" input:value output:value];
}

#pragma mark - Big Int

- (void)testBigIntWithNull
{
	id value = [NSNull null];
	[self testCast:@"BIGINT" input:nil output:value];
}

- (void)testBigIntWithMinimum
{
	id value = @(LLONG_MIN);
	[self testCast:@"BIGINT" input:value output:value];
}

- (void)testBigIntWithMaximum
{
	id value = @(LLONG_MAX);
	[self testCast:@"BIGINT" input:value output:value];
}

#pragma mark - Float

- (void)testFloatWithNull
{
	id value = [NSNull null];
	[self testCast:@"FLOAT" input:nil output:value];
}

- (void)testFloatWithMinimum
{
	id value = @(-1.79e+308);
	[self testCast:@"FLOAT" input:value output:value];
}

- (void)testFloatWithMaximum
{
	id value = @(1.79e+308);
	[self testCast:@"FLOAT" input:value output:value];
}

#pragma mark - Real

- (void)testRealWithNull
{
	id value = [NSNull null];
	[self testCast:@"REAL" input:nil output:value];
}

- (void)testRealWithMinimum
{
	id value = [NSNumber numberWithFloat:-3.4e+38];
	[self testCast:@"REAL" input:value output:value];
}

- (void)testRealWithMaximum
{
	id value = [NSNumber numberWithFloat:3.4e+38];
	[self testCast:@"REAL" input:value output:value];
}

#pragma mark - Decimal

- (void)testDecimalWithNull
{
	id value = [NSNull null];
	[self testCast:@"DECIMAL" input:nil output:value];
}

- (void)testDecimalWithMinimum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:YES] decimalNumberByAdding:[NSDecimalNumber one]];
	[self testCast:@"DECIMAL(38,0)" input:value output:value];
}

- (void)testDecimalWithMaximum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:NO] decimalNumberBySubtracting:[NSDecimalNumber one]];
	[self testCast:@"DECIMAL(38,0)" input:value output:value];
}

#pragma mark - Numeric

- (void)testNumericWithNull
{
	id value = [NSNull null];
	[self testCast:@"NUMERIC" input:nil output:value];
}

- (void)testNumericWithMinimum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:YES] decimalNumberByAdding:[NSDecimalNumber one]];
	[self testCast:@"NUMERIC(38,0)" input:value output:value];
}

- (void)testNumericWithMaximum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:NO] decimalNumberBySubtracting:[NSDecimalNumber one]];
	[self testCast:@"NUMERIC(38,0)" input:value output:value];
}

#pragma mark - Small Money

- (void)testSmallMoneyWithNull
{
	id value = [NSNull null];
	[self testCast:@"SMALLMONEY" input:nil output:value];
}

- (void)testSmallMoneyWithMinimum
{
	id value = [NSDecimalNumber decimalNumberWithString:@"-214748.3648"];
	[self testCast:@"SMALLMONEY" input:value output:value];
}

- (void)testSmallMoneyWithMaximum
{
	id value = [NSDecimalNumber decimalNumberWithString:@"214748.3647"];
	[self testCast:@"SMALLMONEY" input:value output:value];
}

#pragma mark - Money

- (void)testMoneyWithNull
{
	id value = [NSNull null];
	[self testCast:@"MONEY" input:nil output:value];
}

- (void)testMoneyWithMinimum
{
	//TODO: fix last 2 digits, i.e. -922337203685477.5808 returns -922337203685477.58
	id value = [NSDecimalNumber decimalNumberWithString:@"-922337203685477.58"];
	[self testCast:@"MONEY" input:value output:value];
}

- (void)testMoneyWithMaximum
{
	//TODO: fix last 2 digits, i.e. 922337203685477.5807 returns 922337203685477.58
	id value = [NSDecimalNumber decimalNumberWithString:@"922337203685477.58"];
	[self testCast:@"MONEY" input:value output:value];
}

#pragma mark - Small DateTime

- (void)testSmallDateTimeWithNull
{
	id value = [NSNull null];
	[self testCast:@"SMALLDATETIME" input:nil output:value];
}

- (void)testSmallDateTimeWithMinimum
{
	id value = @"01-01-1900 00:00:00";
	id output = [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testCast:@"SMALLDATETIME" input:value output:output];
}

- (void)testSmallDateTimeWithMaximum
{
	id value = @"06-06-2079 23:59:00";
	id output = [self dateWithYear:2079 month:6 day:6 hour:23 minute:59 second:0 nanosecond:0 timezone:0];
	[self testCast:@"SMALLDATETIME" input:value output:output];
}

#pragma mark - DateTime

- (void)testDateTimeWithNull
{
	id value = [NSNull null];
	[self testCast:@"DATETIME" input:nil output:value];
}

- (void)testDateTimeWithMinimum
{
	id value = @"01-01-1753 00:00:00:000";
	id output = [self dateWithYear:1753 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testCast:@"DATETIME" input:value output:output];
}

- (void)testDateTimeWithMaximum
{
	id value = @"12-31-9999 23:59:59:997";
	id output = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:997000000 timezone:0];
	[self testCast:@"DATETIME" input:value output:output];
}

#pragma mark - DateTime2

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateTime2WithNull
{
	id value = [NSNull null];
	[self testCast:@"DATETIME2" input:nil output:value];
}

- (void)testDateTime2WithMinimum
{
	id value = @"01-01-0001 00:00:00.0000000";
	id output = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testCast:@"DATETIME2" input:value output:output];
}

- (void)testDateTime2WithMaximum
{
	id value = @"12-31-9999 23:59:59.9999999";
	id output = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0];
	[self testCast:@"DATETIME2" input:value output:output];
}

#pragma mark - DateTimeOffset

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateTimeOffsetWithNull
{
	id value = [NSNull null];
	[self testCast:@"DATETIMEOFFSET" input:nil output:value];
}

- (void)testDateTimeOffsetWithMinimum
{
	id value = @"01-01-0001 00:00:00.0000000 -14:00";
	id output = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:-840];
	[self testCast:@"DATETIMEOFFSET" input:value output:output];
}

- (void)testDateTimeOffsetWithMaximum
{
	id value = @"12-31-9999 23:59:59.9999999 +14:00";
	id output = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:840];
	[self testCast:@"DATETIMEOFFSET" input:value output:output];
}

#pragma mark - Date

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateWithNull
{
	id value = [NSNull null];
	[self testCast:@"DATE" input:nil output:value];
}

- (void)testDateWithMinimum
{
	id value = @"01-01-0001";
	id output = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testCast:@"DATE" input:value output:output];
}

- (void)testDateWithMaximum
{
	id value = @"12-31-9999";
	id output = [self dateWithYear:9999 month:12 day:31 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testCast:@"DATE" input:value output:output];
}

#pragma mark - Time

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testTimeWithNull
{
	id value = [NSNull null];
	[self testCast:@"TIME" input:nil output:value];
}

- (void)testTimeWithMinimum
{
	id value = @"00:00:00.0000000";
	id output = [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testCast:@"TIME" input:value output:output];
}

- (void)testTimeWithMaximum
{
	id value = @"23:59:59.9999999";
	id output = [self dateWithYear:1900 month:1 day:1 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0];
	[self testCast:@"TIME" input:value output:output];
}

#pragma mark - Char

- (void)testCharWithNull
{
	id value = [NSNull null];
	[self testCast:@"CHAR(1)" input:nil output:value];
}

- (void)testCharWithMinimum
{
	//TODO: Fix (32 doesn't work)
	//33 = minimum ASCII value
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testCast:@"CHAR(1)" input:value output:value];
}

- (void)testCharWithMaximum
{
	//127 = maximum printable ASCII value
	id value = [NSString stringWithFormat:@"%c", 127];
	[self testCast:@"CHAR(1)" input:value output:value];
}

#pragma mark - VarChar(Max)

- (void)testVarCharMaxWithNull
{
	id value = [NSNull null];
	[self testCast:@"VARCHAR(MAX)" input:nil output:value];
}

- (void)testVarCharMaxWithMinimum
{
	//TODO: Fix (32 doesn't work)
	//33 = minimum ASCII value
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testCast:@"VARCHAR(MAX)" input:value output:value];
}

- (void)testVarCharMaxWithMaximum
{
	id value = [self stringWithLength:[SQLClient sharedInstance].maxTextSize + 1];
	id output = [value substringToIndex:[SQLClient sharedInstance].maxTextSize - 1];
	[self testCast:@"VARCHAR(MAX)" input:value output:output];
}

#pragma mark - Text

- (void)testTextWithNull
{
	id value = [NSNull null];
	[self testCast:@"TEXT" input:nil output:value];
}

- (void)testTextWithMinimum
{
	//TODO: Fix (32 doesn't work)
	//33 = minimum ASCII value
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testCast:@"TEXT" input:value output:value];
}

- (void)testTextWithMaximum
{
	id value = [self stringWithLength:[SQLClient sharedInstance].maxTextSize + 1];
	id output = [value substringToIndex:[SQLClient sharedInstance].maxTextSize - 1];
	[self testCast:@"TEXT" input:value output:output];
}

#pragma mark - UniqueIdentifier

- (void)testUniqueIdentifierWithNull
{
	id value = [NSNull null];
	[self testCast:@"UNIQUEIDENTIFIER" input:nil output:value];
}

- (void)testUniqueIdentifierWithValue
{
	id output = [NSUUID UUID];
	id value = [output UUIDString];
	[self testCast:@"UNIQUEIDENTIFIER" input:value output:output];
}

#pragma mark - Binary

- (void)testBinaryWithNull
{
	id value = [NSNull null];
	[self testCast:@"BINARY" input:nil output:value];
}

- (void)testBinaryWithValue
{
	NSString* string = [self stringWithLength:30];
	NSData* data = [string dataUsingEncoding:NSASCIIStringEncoding];
	NSString* hex = [self hexStringWithData:data];
	[self testConvert:@"BINARY" style:1 input:hex output:data];
}

#pragma mark - VarBinary

- (void)testVarBinaryWithNull
{
	id value = [NSNull null];
	[self testCast:@"VARBINARY" input:nil output:value];
}

- (void)testVarBinaryWithValue
{
	NSString* string = [self stringWithLength:30];
	NSData* data = [string dataUsingEncoding:NSASCIIStringEncoding];
	NSString* hex = [self hexStringWithData:data];
	[self testConvert:@"VARBINARY" style:1 input:hex output:data];
}

#pragma mark - Multiple Tables

- (void)testMultipleTables
{
	NSString* sql = @"SELECT * FROM (VALUES (1), (2), (3)) AS Table1(a); SELECT * FROM (VALUES (4), (5), (6)) AS Table2(b);";
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"a"], @(1));
		XCTAssertEqualObjects(results[0][1][@"a"], @(2));
		XCTAssertEqualObjects(results[0][2][@"a"], @(3));
		XCTAssertEqualObjects(results[1][0][@"b"], @(4));
		XCTAssertEqualObjects(results[1][1][@"b"], @(5));
		XCTAssertEqualObjects(results[1][2][@"b"], @(6));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

#pragma mark - Private

- (void)testCast:(NSString*)serverType input:(id)input output:(id)output
{
	NSString* sql;
	if (input) {
		sql = [NSString stringWithFormat:@"SELECT CAST('%@' AS %@) AS Value", input, serverType];
	} else {
		sql = [NSString stringWithFormat:@"SELECT CAST(NULL AS %@) AS Value", serverType];
	}

	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Value"], output);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testConvert:(NSString*)serverType style:(int)style input:(id)input output:(id)output
{
	NSString* sql = [NSString stringWithFormat:@"SELECT CONVERT(%@, '%@', %d) AS Value", serverType, input, style];
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Value"], output);
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

- (NSString*)hexStringWithData:(NSData*)data
{
	const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
	if (!dataBuffer) {
		return [NSString string];
	}
	
	NSMutableString* output = [NSMutableString stringWithCapacity:(data.length * 2)];
	for (int i = 0; i < data.length; ++i) {
		[output appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
	}
	return [NSString stringWithFormat:@"0x%@", output];
}

@end
