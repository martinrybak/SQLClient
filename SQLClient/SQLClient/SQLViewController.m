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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.spinner setHidesWhenStopped:YES];
	[self connect];
}

#pragma mark - Private

- (void)connect
{
	SQLClient* client = [SQLClient sharedInstance];
	client.delegate = self;
	
	[self.spinner startAnimating];
	[client connect:@"server:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
		[self.spinner stopAnimating];
		if (success) {
			[self execute];
		}
	}];
}

- (void)execute
{
	SQLClient* client = [SQLClient sharedInstance];
	
	[self.spinner startAnimating];
	[client execute:@"SELECT * FROM Users" completion:^(NSArray* results) {
		[self.spinner stopAnimating];
		[self process:results];
		[client disconnect];
	}];
}

- (void)process:(NSArray*)results
{
	NSMutableString* output = [[NSMutableString alloc] init];
	for (NSArray* table in results) {
		for (NSDictionary* row in table) {
			for (NSString* column in row) {
				[output appendFormat:@"\n%@=%@", column, row[column]];
			}
		}
	}
	self.textView.text = output;
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
