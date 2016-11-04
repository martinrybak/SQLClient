//
//  MRGridCollectionView.m
//  SQLClient
//
//  Created by Martin Rybak on 11/4/16.
//  Copyright © 2016 Martin Rybak. All rights reserved.
//

#import "MRGridCollectionView.h"
#import "MRGridCollectionViewLayout.h"
#import "MRGridCollectionViewCell.h"

@implementation MRGridCollectionView

#pragma mark - UIViewController

- (instancetype)init
{
	MRGridCollectionViewLayout* layout = [[MRGridCollectionViewLayout alloc] init];
	if (self = [super initWithFrame:CGRectZero collectionViewLayout:layout]) {
		self.dataSource = self;
		self.delegate = self;
		self.directionalLockEnabled = YES;
		self.alwaysBounceVertical = YES;
		self.layout = layout;
		[self registerNib:[UINib nibWithNibName:[MRGridCollectionViewCell description] bundle:nil] forCellWithReuseIdentifier:[MRGridCollectionViewCell description]];
	}
	return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
	return [self.gridDataSource numberOfColumns];
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.gridDataSource numberOfRows];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
	MRGridCollectionViewCell* cell = [self dequeueReusableCellWithReuseIdentifier:[MRGridCollectionViewCell description] forIndexPath:indexPath];
	cell.backgroundColor = indexPath.row % 2 ? [UIColor whiteColor] : [UIColor lightGrayColor];
	cell.label.text = [self.gridDataSource valueForRow:indexPath.row column:indexPath.section];
	return cell;
}

@end
