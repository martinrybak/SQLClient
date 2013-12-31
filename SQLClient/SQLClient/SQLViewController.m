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

@property (weak, nonatomic) IBOutlet UITextView* textView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinner;

@end

@implementation SQLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.spinner setHidesWhenStopped:YES];
    [self.spinner startAnimating];
	   
	SQLClient* client = [SQLClient sharedInstance];
	client.delegate = self;
	[client connect:@"server:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
		if (success)
		{
			[client execute:@"SELECT * FROM Users" completion:^(NSArray* results) {
                [self.spinner stopAnimating];
				[self process:results];
                [client disconnect];
			}];
		}
		else
			[self.spinner stopAnimating];
	}];
}

- (void)process:(NSArray*)data
{
	NSMutableString* results = [[NSMutableString alloc] init];
	for (NSArray* table in data)
		for (NSDictionary* row in table)
			for (NSString* column in row)
				[results appendFormat:@"\n%@=%@", column, row[column]];
	self.textView.text = results;
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
