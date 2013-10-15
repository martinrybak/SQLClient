//
//  SQLViewController.m
//  SQLClient
//
//  Created by Martin Rybak on 10/14/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "SQLViewController.h"
#import "SQLClient.h"

@interface SQLViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinner;

@end

@implementation SQLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	SQLClient* client = [SQLClient sharedInstance];
	client.delegate = self;
	[self.spinner startAnimating];
    [self.spinner setHidesWhenStopped:YES];
    
	[client connect:@"server:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
		if (success)
		{
			[client execute:@"SELECT * FROM Users" completion:^(NSArray* results) {
                for (NSArray* table in results)
                    for (NSDictionary* row in table)
                        for (NSString* column in row)
                            NSLog(@"%@=%@", column, row[column]);
                [self.spinner stopAnimating];
                [client disconnect];
			}];
		}
        else
            [self.spinner stopAnimating];
	}];
}

#pragma mark - SQLClientDelegate

//Required
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
	NSLog(@"Error #%d: %@ (Severity %d)", code, error, severity);
	[[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

//Optional
- (void)message:(NSString*)message
{
	NSLog(@"Message: %@", message);
}

@end
