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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(error:) name:SQLClientErrorNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(message:) name:SQLClientMessageNotification object:nil];

	[self connect];
}

#pragma mark - Private

- (void)connect
{
	SQLClient* client = [SQLClient sharedInstance];
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

#pragma mark - SQLClientErrorNotification

- (void)error:(NSNotification*)notification
{
	NSNumber* code = notification.userInfo[SQLClientCodeKey];
	NSString* message = notification.userInfo[SQLClientMessageKey];
	NSNumber* severity = notification.userInfo[SQLClientSeverityKey];
	
	NSLog(@"Error #%@: %@ (Severity %@)", code, message, severity);
	[[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

#pragma mark - SQLClientMessageNotification

- (void)message:(NSNotification*)notification
{
	NSString* message = notification.userInfo[SQLClientMessageKey];
	NSLog(@"Message: %@", message);
}

@end
