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

@property (strong, nonatomic) UITextView* textView;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;

@end

@implementation SQLViewController

#pragma mark - NSObject

- (instancetype)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(error:) name:SQLClientErrorNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(message:) name:SQLClientMessageNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)loadView
{
	self.view = [[UIView alloc] init];
	
	//Load textView
	UITextView* textView = [[UITextView alloc] init];
	textView.editable = NO;
	textView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:textView];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
	self.textView = textView;
	
	//Load spinner
	UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.hidesWhenStopped = YES;
	spinner.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:spinner];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[spinner]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(spinner)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[spinner]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(spinner)]];
	self.spinner = spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self connect];
}

#pragma mark - Private

- (void)connect
{
	SQLClient* client = [SQLClient sharedInstance];
	[self.spinner startAnimating];
	[client connect:@"server\\instance:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
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
	[client execute:@"SELECT * FROM Table" completion:^(NSArray* results) {
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
