SQLClient
=========

Native SQL Server client for iOS. An Objective-C wrapper around the open-source FreeTDS library.

##Sample Usage

<pre>
&#35;import "SQLClient.h"

SQLClient* client = [SQLClient sharedInstance];
client.delegate = self;
[client connect:@"server:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
    if (success)
    {
      [client execute:@"SELECT * FROM Users" completion:^(NSArray* results) {
        for (NSArray* table in results)
          for (NSDictionary* row in table)
            for (NSString* column in row)
              NSLog(@"%@=%@", column, row[column]);
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

##Demo Project
Open the Xcode project in the SQLClient folder.


##Installation

1. Copy the contents of the **SQLClient/SQLClient/SQLClient** folder into your project.
2. Go to Project > Build Phases > Link Binary With Libraries. Click + and add **libiconv.dylib**.

##Documentation

<a href="http://htmlpreview.github.io/?https://raw.github.com/martinrybak/SQLClient/master/SQLClient/SQLClientDocs/html/Classes/SQLClient.html">SQLClient Class Reference</a>

<a href="http://wp.me/p3o7rD-cY">Blog Post</a>

##Credits:

FreeTDS
http://www.freetds.org

FreeTDS-iOS
https://github.com/patchhf/FreeTDS-iOS

FreeTDS example code in C:
http://lists.ibiblio.org/pipermail/freetds/2007q4/022482.html
