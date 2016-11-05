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

@property (strong, nonatomic) NSArray* results;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.collectionView.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.80 alpha:1.00];
	self.searchBar.returnKeyType = UIReturnKeyGo;
	[self connect];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
	[self execute:searchBar.text];
}

#pragma mark - MRGridCollectionViewControllerDataSource

- (NSUInteger)numberOfColumns
{
	NSArray* table = self.results[0];
	NSDictionary* firstRow = table.firstObject;
	return firstRow.allKeys.count;
}

- (NSUInteger)numberOfRows
{
	NSArray* table = self.results[0];
	return table.count;
}

- (NSString*)titleForColumn:(NSUInteger)column
{
	NSArray* table = self.results[0];
	NSDictionary* firstRow = table.firstObject;
	NSArray* columns = [firstRow.allKeys sortedArrayUsingSelector:@selector(compare:)];
	return columns[column];
}

- (id)valueForRow:(NSUInteger)row column:(NSUInteger)column
{
	NSArray* table = self.results[0];
	NSDictionary* dictionary = table[row];
	NSArray* columns = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
	return [dictionary[columns[column]] description];
}

#pragma mark - Private

- (void)connect
{
	SQLClient* client = [SQLClient sharedInstance];
	[self.spinner startAnimating];
	self.view.userInteractionEnabled = NO;
	[client connect:@"server\\instance:port" username:@"user" password:@"pass" database:@"db" completion:^(BOOL success) {
		[self.spinner stopAnimating];
		self.view.userInteractionEnabled = YES;
		if (success) {
//			[self execute];
		}
	}];
}

- (void)execute:(NSString*)sql
{
	if (![SQLClient sharedInstance].isConnected) {
		[self connect];
		return;
	}
	
	[self.spinner startAnimating];
	self.view.userInteractionEnabled = NO;
	[[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
		[self.spinner stopAnimating];
		self.view.userInteractionEnabled = YES;
		self.results = results;
		[self.collectionView reloadData];
	}];
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
