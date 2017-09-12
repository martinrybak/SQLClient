SQLClient
=========

Native Microsoft SQL Server client for iOS. An Objective-C wrapper around the open-source [FreeTDS](https://github.com/FreeTDS/freetds/) library.

## Sample Usage

<pre>
&#35;import "SQLClient.h"

SQLClient* client = [SQLClient sharedInstance];
[client connect:@"server\instance:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
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
</pre>

## Errors

FreeTDS communicates both errors and messages. `SQLClient` rebroadcasts both via `NSNotificationCenter`:

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(error:) name:SQLClientErrorNotification object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(message:) name:SQLClientMessageNotification object:nil];	

- (void)error:(NSNotification*)notification
{
	NSNumber* code = notification.userInfo[SQLClientCodeKey];
	NSString* message = notification.userInfo[SQLClientMessageKey];
	NSNumber* severity = notification.userInfo[SQLClientSeverityKey];
	NSLog(@"Error #%@: %@ (Severity %@)", code, message, severity);
}

- (void)message:(NSNotification*)notification
{
	NSString* message = notification.userInfo[SQLClientMessageKey];
	NSLog(@"Message: %@", message);
}
```

## Type Conversion
SQLClient maps SQL Server data types into the following native Objective-C types:

* bigint → NSNumber
* binary(n) → NSData
* bit → NSNumber
* char(n) → NSString
* cursor → **not supported**
* date → **NSDate** or **NSString**†
* datetime → NSDate
* datetime2 → **NSDate** or **NSString**†
* datetimeoffset → **NSDate** or **NSString**†
* decimal(p,s) → NSNumber
* float(n) → NSNumber
* image → **NSData**
* int → NSNumber
* money → NSDecimalNumber **(last 2 digits are truncated)**
* nchar → NSString
* ntext → NSString
* null → NSNull
* numeric(p,s) → NSNumber
* nvarchar → NSString
* nvarchar(max) → NSString
* real → NSNumber
* smalldatetime → NSDate
* smallint → NSNumber
* smallmoney → NSDecimalNumber
* sql_variant → **not supported**
* table → **not supported**
* text → NSString*
* time → **NSDate** or **NSString**†
* timestamp → NSData
* tinyint → NSNumber
* uniqueidentifier → NSUUID
* varbinary → NSData
* varbinary(max) → NSData
* varchar(max) → NSString*
* varchar(n) → NSString
* xml → NSString

\*The maximum length of a string in a query is configured on the server via the `SET TEXTSIZE` command. To find out your current setting, execute `SELECT @@TEXTSIZE`. SQLClient uses **4096** by default. To override this setting, update the `maxTextSize` property.

†The following data types are only converted to **NSDate** on TDS version **7.3** and higher. By default FreeTDS uses version **7.1** of the TDS protocol, which converts them to **NSString**. To use a higher version of the TDS protocol, add an environment variable to Xcode named `TDSVER`. Possible values are
`4.2`, `5.0`, `7.0`, `7.1`, `7.2`, `7.3`, `7.4`, `auto`.
A value of `auto` tells FreeTDS to use an autodetection (trial-and-error) algorithm to choose the highest available protocol version.

* date
* datetime2
* datetimeoffset
* time

## Testing

The `SQLClientTests` target contains integration tests which require a connection to an instance of SQL Server. The integration tests have passed successfully on the following database servers:

* SQL Server 7.0 (TDS 7.0)
* SQL Server 2000 (TDS 7.1)
* SQL Server 2005 (TDS 7.2)
* SQL Server 2008 (TDS 7.3)
* **TODO: add more!**

To configure the connection for your server:

* In Xcode, go to `Edit Scheme...` and select the `Test` scheme.
* On the `Arguments` tab, uncheck `Use the Run action's arguments and environment variables`
* Add the following environment variables for your server. The values should be the same as you pass in to the `connect:` method.
	* `HOST` (`server\instance:port`)
	* `DATABASE` (optional)
	* `USERNAME`
	* `PASSWORD`

## Known Issues
PR's welcome!

* **strings**: FreeTDS incorrectly returns an empty string "" for a single space " "
* **money**: FreeTDS will truncate the rightmost 2 digits.
* OSX support: [FreeTDS-iOS](https://github.com/martinrybak/FreeTDS-iOS) needs to be compiled to support OSX and Podspec updated
* No support for stored procedures with out parameters (yet)
* No support for returning number of rows changed (yet)
* Swift bindings: I welcome a PR to make the API more Swift-friendly

##Demo Project
Open the Xcode project inside the **SQLClient** folder.


## Installation

### CocoaPods

<a href="http://cocoapods.org/?q=sqlclient">CocoaPods</a> is the preferred way to install this library.

1. Open a Terminal window. Update RubyGems by entering: `sudo gem update --system`. Enter your password when prompted.
2. Install CocoaPods by entering `sudo gem install cocoapods`.
3. Create a file at the root of your Xcode project folder called **Podfile**.
4. Enter the following text: `pod 'SQLClient', '~> 1.0.0'`
4. In Terminal navigate to this folder and enter `pod install`.
5. You will see a new **SQLClient.xcworkspace** file. Open this file in Xcode to work with this project from now on.

### Manual

1. Drag and drop the contents of the **SQLClient/SQLClient/SQLClient** folder into your Xcode project.
2. Select **Copy items into destination group's folder (if needed)**.
3. Go to Project > Build Phases > Link Binary With Libraries.
3. Click + and add **libiconv.dylib**.

## Documentation

<a href="http://htmlpreview.github.io/?https://raw.github.com/martinrybak/SQLClient/master/SQLClient/SQLClientDocs/html/index.html">SQLClient Class Reference</a>

<a href="http://wp.me/p3o7rD-cY">SQLClient: A Native Microsoft SQL Server Library for iOS</a>

## Credits

FreeTDS:
http://www.freetds.org

FreeTDS-iOS:
https://github.com/patchhf/FreeTDS-iOS

FreeTDS example code in C:
http://freetds.schemamania.org/userguide/samplecode.htm

SQL Server Logo
© Microsoft
