//
//  SQLViewController.m
//  SQLClient
//
//  Created by Martin Rybak on 10/14/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "SQLViewController.h"
#import "MRGridCollectionView.h"
#import "SQLClient.h"

@interface SQLViewController ()

@property (strong, nonatomic) MRGridCollectionView* collectionView;
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
	
	//Load collection view
	MRGridCollectionView* collectionView = [[MRGridCollectionView alloc] init];
	collectionView.backgroundColor = [UIColor darkGrayColor];
	collectionView.gridDataSource = self;
	collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:collectionView];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(collectionView)]];
	self.collectionView = collectionView;
	
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
//	[self connect];
}

#pragma mark - MRGridCollectionViewControllerDataSource

- (NSUInteger)numberOfColumns
{
	return 2;
}

- (NSUInteger)numberOfRows
{
	return 10;
}

- (NSString*)titleForColumn:(NSUInteger)column
{
	return @"Foo";
}

- (id)valueForRow:(NSUInteger)row column:(NSUInteger)column
{
	return @"Bar";
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
