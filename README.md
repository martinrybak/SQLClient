SQLClient
=========

Native Microsoft SQL Server client for iOS. An Objective-C wrapper around the open-source [FreeTDS](https://github.com/FreeTDS/freetds/) library.

##Sample Usage

<pre>
&#35;import "SQLClient.h"

SQLClient* client = [SQLClient sharedInstance];
client.delegate = self;
[client connect:@"server:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
    if (success) {
      [client execute:@"SELECT * FROM Users" completion:^(NSArray* results) {
        for (NSArray* table in results) {
          for (NSDictionary* row in table) {
            for (NSString* column in row) {
              NSLog(@"%@=%@", column, row[column]);
            }
          }
        }             
        [client disconnect];
      }];
    }
}];

//Required
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
  NSLog(@"Error #%d: %@ (Severity %d)", code, error, severity);
}
</pre>

##Type Conversion
SQLClient maps SQL Server data types into the following native Objective-C objects:

* bigint → NSNumber
* binary(n) → NSData
* bit → NSNumber
* char(n) → NSString
* cursor → **not supported**
* date → **NSString**
* datetime → NSDate
* datetime2 → **NSString**
* datetimeoffset → **NSString**
* decimal(p,s) → NSNumber
* float(n) → NSNumber
* image → UIImage
* int → NSNumber
* money → NSDecimalNumber **(last 2 digits are truncated)**
* nchar → NSString
* ntext → NSString
* numeric(p,s) → NSNumber
* nvarchar → NSString
* nvarchar(max) → NSString
* real → NSNumber
* smalldatetime → NSDate
* smallint → NSNumber
* smallmoney → NSDecimalNumber
* sql_variant → **not supported**
* table → **not supported**
* text → NSString
* time → **NSString**
* timestamp → **NSData**
* tinyint → NSNumber
* uniqueidentifier → NSUUID
* varbinary → NSData
* varbinary(max) → NSData
* varchar(max) → NSString
* varchar(n) → NSString
* xml → NSString

##Testing

The type conversions have been tested with SQL Server 2008 R2.

## Known Issues
PR's welcome!

* **money**: FreeTDS will truncate the rightmost 2 digits.
* The following data types are recognized by FreeTDS as type **SYBCHAR**, so SQLClient can't convert them into proper **NSDate** objects: 
 	* date
	* datetime2
	* datetimeoffset
	* time
* OSX support: [FreeTDS-iOS](https://github.com/martinrybak/FreeTDS-iOS) needs to be compiled to support OSX, Podspec updated
* No support for stored procedures with out parameters (yet)
* No support for returning number of rows changed (yet)
* Swift bindings: I welcome a PR to make the API more Swift-friendly


##Demo Project
Open the Xcode project inside the **SQLClient** folder.


##Installation

###CocoaPods

<a href="http://cocoapods.org/?q=sqlclient">CocoaPods</a> is the preferred way to install this library.

1. Open a Terminal window. Update RubyGems by entering: `sudo gem update --system`. Enter your password when prompted.
2. Install CocoaPods by entering `sudo gem install cocoapods`.
3. Create a file at the root of your Xcode project folder called **Podfile**.
4. Enter the following text: `pod 'SQLClient', '~> 0.1.3'`
4. In Terminal navigate to this folder and enter `pod install`.
5. You will see a new **SQLClient.xcworkspace** file. Open this file in Xcode to work with this project from now on.

###Manual

1. Drag and drop the contents of the **SQLClient/SQLClient/SQLClient** folder into your Xcode project.
2. Select **Copy items into destination group's folder (if needed)**.
3. Go to Project > Build Phases > Link Binary With Libraries.
3. Click + and add **libiconv.dylib**.

##Documentation

<a href="http://htmlpreview.github.io/?https://raw.github.com/martinrybak/SQLClient/master/SQLClient/SQLClientDocs/html/index.html">SQLClient Class Reference</a>

<a href="http://wp.me/p3o7rD-cY">SQLClient: A Native Microsoft SQL Server Library for iOS</a>

##Credits

FreeTDS:
http://www.freetds.org

FreeTDS-iOS:
https://github.com/patchhf/FreeTDS-iOS

FreeTDS example code in C:
http://freetds.schemamania.org/userguide/samplecode.htm
