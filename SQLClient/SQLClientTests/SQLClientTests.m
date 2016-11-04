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

#pragma mark - CRUD

- (void)testInsert
{
	NSMutableString* sql = [NSMutableString string];
	[sql appendString:@"CREATE TABLE #Temp(Id INT IDENTITY, Name CHAR(20));"];
	[sql appendString:@"INSERT INTO #Temp (Name) VALUES ('Foo');"];
	[sql appendString:@"SELECT @@IDENTITY AS Id;"];
	[sql appendString:@"DROP TABLE #Temp;"];
	
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[1][0][@"Id"], @(1));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testUpdate
{
	NSMutableString* sql = [NSMutableString string];
	[sql appendString:@"CREATE TABLE #Temp(Id INT IDENTITY, Name CHAR(20));"];
	[sql appendString:@"INSERT INTO #Temp (Name) VALUES ('Foo');"];
	[sql appendString:@"UPDATE #Temp SET Name = 'Bar';"];
	[sql appendString:@"SELECT Name FROM #Temp;"];
	[sql appendString:@"DROP TABLE #Temp;"];
	
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[1][0][@"Name"], @"Bar");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testDelete
{
	NSMutableString* sql = [NSMutableString string];
	[sql appendString:@"CREATE TABLE #Temp(Id INT IDENTITY, Name CHAR(20));"];
	[sql appendString:@"INSERT INTO #Temp (Name) VALUES ('Foo');"];
	[sql appendString:@"DELETE FROM #Temp;"];
	[sql appendString:@"SELECT * FROM #Temp;"];
	[sql appendString:@"DROP TABLE #Temp;"];
	
	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertNotNil(results);
		XCTAssertEqual([results[1] count], 0);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:100 handler:nil];
}

#pragma mark - Bit

- (void)testBitWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"BIT" convertsTo:value];
}

- (void)testBitWithTrue
{
	id value = @(YES);
	[self testValue:value ofType:@"BIT" convertsTo:value];
}

- (void)testBitWithFalse
{
	id value = @(YES);
	[self testValue:value ofType:@"BIT" convertsTo:value];
}

#pragma mark - Tiny Int

- (void)testTinyIntWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"TINYINT" convertsTo:value];
}

- (void)testTinyIntWithMinimum
{
	id value = @(0);
	[self testValue:value ofType:@"TINYINT" convertsTo:value];
}

- (void)testTinyIntWithMaximum
{
	id value = @(UCHAR_MAX);
	[self testValue:value ofType:@"TINYINT" convertsTo:value];
}

#pragma mark - Small Int

- (void)testSmallIntWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"SMALLINT" convertsTo:value];
}

- (void)testSmallIntWithMinimum
{
	id value = @(SHRT_MIN);
	[self testValue:value ofType:@"SMALLINT" convertsTo:value];
}

- (void)testSmallIntWithMaximum
{
	id value = @(SHRT_MAX);
	[self testValue:value ofType:@"SMALLINT" convertsTo:value];
}

#pragma mark - Int

- (void)testIntWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"INT" convertsTo:value];
}

- (void)testIntWithMinimum
{
	id value = @(SHRT_MIN);
	[self testValue:value ofType:@"INT" convertsTo:value];
}

- (void)testIntWithMaximum
{
	id value = @(SHRT_MAX);
	[self testValue:value ofType:@"INT" convertsTo:value];
}

#pragma mark - Big Int

- (void)testBigIntWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"BIGINT" convertsTo:value];
}

- (void)testBigIntWithMinimum
{
	id value = @(LLONG_MIN);
	[self testValue:value ofType:@"BIGINT" convertsTo:value];
}

- (void)testBigIntWithMaximum
{
	id value = @(LLONG_MAX);
	[self testValue:value ofType:@"BIGINT" convertsTo:value];
}

#pragma mark - Float

- (void)testFloatWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"FLOAT" convertsTo:value];
}

- (void)testFloatWithMinimum
{
	id value = @(-1.79e+308);
	[self testValue:value ofType:@"FLOAT" convertsTo:value];
}

- (void)testFloatWithMaximum
{
	id value = @(1.79e+308);
	[self testValue:value ofType:@"FLOAT" convertsTo:value];
}

#pragma mark - Real

- (void)testRealWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"REAL" convertsTo:value];
}

- (void)testRealWithMinimum
{
	id value = [NSNumber numberWithFloat:-3.4e+38];
	[self testValue:value ofType:@"REAL" convertsTo:value];
}

- (void)testRealWithMaximum
{
	id value = [NSNumber numberWithFloat:3.4e+38];
	[self testValue:value ofType:@"REAL" convertsTo:value];
}

#pragma mark - Decimal

- (void)testDecimalWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"DECIMAL" convertsTo:value];
}

- (void)testDecimalWithMinimum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:YES] decimalNumberByAdding:[NSDecimalNumber one]];
	[self testValue:value ofType:@"DECIMAL(38,0)" convertsTo:value];
}

- (void)testDecimalWithMaximum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:NO] decimalNumberBySubtracting:[NSDecimalNumber one]];
	[self testValue:value ofType:@"DECIMAL(38,0)" convertsTo:value];
}

#pragma mark - Numeric

- (void)testNumericWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"NUMERIC" convertsTo:value];
}

- (void)testNumericWithMinimum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:YES] decimalNumberByAdding:[NSDecimalNumber one]];
	[self testValue:value ofType:@"NUMERIC(38,0)" convertsTo:value];
}

- (void)testNumericWithMaximum
{
	id value = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:38 isNegative:NO] decimalNumberBySubtracting:[NSDecimalNumber one]];
	[self testValue:value ofType:@"NUMERIC(38,0)" convertsTo:value];
}

#pragma mark - Small Money

- (void)testSmallMoneyWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"SMALLMONEY" convertsTo:value];
}

- (void)testSmallMoneyWithMinimum
{
	id value = [NSDecimalNumber decimalNumberWithString:@"-214748.3648"];
	[self testValue:value ofType:@"SMALLMONEY" convertsTo:value];
}

- (void)testSmallMoneyWithMaximum
{
	id value = [NSDecimalNumber decimalNumberWithString:@"214748.3647"];
	[self testValue:value ofType:@"SMALLMONEY" convertsTo:value];
}

#pragma mark - Money

- (void)testMoneyWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"MONEY" convertsTo:value];
}

- (void)testMoneyWithMinimum
{
	//TODO: fix last 2 digits, i.e. -922337203685477.5808 returns -922337203685477.58
	id value = [NSDecimalNumber decimalNumberWithString:@"-922337203685477.58"];
	[self testValue:value ofType:@"MONEY" convertsTo:value];
}

- (void)testMoneyWithMaximum
{
	//TODO: fix last 2 digits, i.e. 922337203685477.5807 returns 922337203685477.58
	id value = [NSDecimalNumber decimalNumberWithString:@"922337203685477.58"];
	[self testValue:value ofType:@"MONEY" convertsTo:value];
}

#pragma mark - Small DateTime

- (void)testSmallDateTimeWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"SMALLDATETIME" convertsTo:value];
}

- (void)testSmallDateTimeWithMinimum
{
	id input = @"01-01-1900 00:00:00";
	id output = [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testValue:input ofType:@"SMALLDATETIME" convertsTo:output];
}

- (void)testSmallDateTimeWithMaximum
{
	id input = @"06-06-2079 23:59:00";
	id output = [self dateWithYear:2079 month:6 day:6 hour:23 minute:59 second:0 nanosecond:0 timezone:0];
	[self testValue:input ofType:@"SMALLDATETIME" convertsTo:output];
}

#pragma mark - DateTime

- (void)testDateTimeWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"DATETIME" convertsTo:value];
}

- (void)testDateTimeWithMinimum
{
	id input = @"01-01-1753 00:00:00:000";
	id output = [self dateWithYear:1753 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testValue:input ofType:@"DATETIME" convertsTo:output];
}

- (void)testDateTimeWithMaximum
{
	id input = @"12-31-9999 23:59:59:997";
	id output = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:997000000 timezone:0];
	[self testValue:input ofType:@"DATETIME" convertsTo:output];
}

#pragma mark - DateTime2

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateTime2WithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"DATETIME2" convertsTo:value];
}

- (void)testDateTime2WithMinimum
{
	id input = @"01-01-0001 00:00:00.0000000";
	id output = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testValue:input ofType:@"DATETIME2" convertsTo:output];
}

- (void)testDateTime2WithMaximum
{
	id input = @"12-31-9999 23:59:59.9999999";
	id output = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0];
	[self testValue:input ofType:@"DATETIME2" convertsTo:output];
}

#pragma mark - DateTimeOffset

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateTimeOffsetWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"DATETIMEOFFSET" convertsTo:value];
}

- (void)testDateTimeOffsetWithMinimum
{
	id input = @"01-01-0001 00:00:00.0000000 -14:00";
	id output = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:-840];
	[self testValue:input ofType:@"DATETIMEOFFSET" convertsTo:output];
}

- (void)testDateTimeOffsetWithMaximum
{
	id input = @"12-31-9999 23:59:59.9999999 +14:00";
	id output = [self dateWithYear:9999 month:12 day:31 hour:23 minute:59 second:59 nanosecond:999999900 timezone:840];
	[self testValue:input ofType:@"DATETIMEOFFSET" convertsTo:output];
}

#pragma mark - Date

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testDateWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"DATE" convertsTo:value];
}

- (void)testDateWithMinimum
{
	id input = @"01-01-0001";
	id output = [self dateWithYear:1 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testValue:input ofType:@"DATE" convertsTo:output];
}

- (void)testDateWithMaximum
{
	id input = @"12-31-9999";
	id output = [self dateWithYear:9999 month:12 day:31 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testValue:input ofType:@"DATE" convertsTo:output];
}

#pragma mark - Time

//If these tests fail, you must tell FreeTDS to use the TDS protocol >= 7.3.
//Add an environment variable to the test scheme with name TDSVER and value auto

- (void)testTimeWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"TIME" convertsTo:value];
}

- (void)testTimeWithMinimum
{
	id input = @"00:00:00.0000000";
	id output = [self dateWithYear:1900 month:1 day:1 hour:0 minute:0 second:0 nanosecond:0 timezone:0];
	[self testValue:input ofType:@"TIME" convertsTo:output];
}

- (void)testTimeWithMaximum
{
	id input = @"23:59:59.9999999";
	id output = [self dateWithYear:1900 month:1 day:1 hour:23 minute:59 second:59 nanosecond:999999900 timezone:0];
	[self testValue:input ofType:@"TIME" convertsTo:output];
}

#pragma mark - Char

- (void)testCharWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"CHAR(1)" convertsTo:value];
}

- (void)testCharWithMinimum
{
	//TODO: Fix (32 doesn't work)
	//33 = minimum ASCII value
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testValue:value ofType:@"CHAR(1)" convertsTo:value];
}

- (void)testCharWithMaximum
{
	//127 = maximum printable ASCII value
	id value = [NSString stringWithFormat:@"%c", 127];
	[self testValue:value ofType:@"CHAR(1)" convertsTo:value];
}

#pragma mark - VarChar(Max)

- (void)testVarCharMaxWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"VARCHAR(MAX)" convertsTo:value];
}

- (void)testVarCharMaxWithMinimum
{
	//TODO: Fix (32 doesn't work)
	//33 = minimum ASCII value
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testValue:value ofType:@"VARCHAR(MAX)" convertsTo:value];
}

- (void)testVarCharMaxWithMaximum
{
	id input = [self stringWithLength:[SQLClient sharedInstance].maxTextSize + 1];
	id output = [input substringToIndex:[SQLClient sharedInstance].maxTextSize - 1];
	[self testValue:input ofType:@"VARCHAR(MAX)" convertsTo:output];
}

#pragma mark - Text

- (void)testTextWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"TEXT" convertsTo:value];
}

- (void)testTextWithMinimum
{
	//TODO: Fix (32 doesn't work)
	//33 = minimum ASCII value
	id value = [NSString stringWithFormat:@"%c", 33];
	[self testValue:value ofType:@"TEXT" convertsTo:value];
}

- (void)testTextWithMaximum
{
	id input = [self stringWithLength:[SQLClient sharedInstance].maxTextSize + 1];
	id output = [input substringToIndex:[SQLClient sharedInstance].maxTextSize - 1];
	[self testValue:input ofType:@"TEXT" convertsTo:output];
}

#pragma mark - UniqueIdentifier

- (void)testUniqueIdentifierWithNull
{
	id value = [NSNull null];
	[self testValue:nil ofType:@"UNIQUEIDENTIFIER" convertsTo:value];
}

- (void)testUniqueIdentifierWithValue
{
	id output = [NSUUID UUID];
	id input = [output UUIDString];
	[self testValue:input ofType:@"UNIQUEIDENTIFIER" convertsTo:output];
}

#pragma mark - Binary

- (void)testBinaryWithNull
{
	id value = [NSNull null];
	[self testBinaryValue:nil ofType:@"BINARY" convertsTo:value withStyle:1];
}

- (void)testBinaryWithValue
{
	NSString* string = [self stringWithLength:30];
	NSData* output = [string dataUsingEncoding:NSASCIIStringEncoding];
	NSString* input = [self hexStringWithData:output];
	[self testBinaryValue:input ofType:@"BINARY" convertsTo:output withStyle:1];
}

#pragma mark - VarBinary

- (void)testVarBinaryWithNull
{
	id value = [NSNull null];
	[self testBinaryValue:nil ofType:@"VARBINARY" convertsTo:value withStyle:1];
}

- (void)testVarBinaryWithValue
{
	NSString* string = [self stringWithLength:30];
	NSData* output = [string dataUsingEncoding:NSASCIIStringEncoding];
	NSString* input = [self hexStringWithData:output];
	[self testBinaryValue:input ofType:@"VARBINARY" convertsTo:output withStyle:1];
}

#pragma mark - Multiple Tables

- (void)testSelectMultipleTables
{
	NSMutableString* sql = [NSMutableString string];
	[sql appendString:@"SELECT 'Bar' AS Foo;"];
	[sql appendString:@"SELECT 'Foo' AS Bar;"];

	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Foo"], @"Bar");
		XCTAssertEqualObjects(results[1][0][@"Bar"], @"Foo");
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

#pragma mark - Private

- (void)testValue:(id)input ofType:(NSString*)type convertsTo:(id)output
{
	NSString* sql;
	if (input) {
		sql = [NSString stringWithFormat:@"SELECT CAST('%@' AS %@) AS Value", input, type];
	} else {
		sql = [NSString stringWithFormat:@"SELECT CAST(NULL AS %@) AS Value", type];
	}

	XCTestExpectation* expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	[self execute:sql completion:^(NSArray* results) {
		XCTAssertEqualObjects(results[0][0][@"Value"], output);
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:[SQLClient sharedInstance].timeout handler:nil];
}

- (void)testBinaryValue:(id)input ofType:(NSString*)type convertsTo:(id)output withStyle:(int)style
{
	NSString* sql;
	if (input) {
		sql = [NSString stringWithFormat:@"SELECT CONVERT(%@, '%@', %d) AS Value", type, input, style];
	} else {
		sql = [NSString stringWithFormat:@"SELECT CONVERT(%@, NULL, %d) AS Value", type, style];
	}
	
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
