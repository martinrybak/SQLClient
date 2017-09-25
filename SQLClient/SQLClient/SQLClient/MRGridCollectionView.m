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

#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		self.dataSource = self;
		self.delegate = self;
		[self registerNib:[UINib nibWithNibName:[MRGridCollectionViewCell description] bundle:nil] forCellWithReuseIdentifier:[MRGridCollectionViewCell description]];
	}
	return self;
}

#pragma mark - UICollectionView

- (void)reloadData
{
	[(MRGridCollectionViewLayout*)self.collectionViewLayout reset];
	[super reloadData];
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
	cell.backgroundColor = [self.gridDataSource backgroundColorForRow:indexPath.row column:indexPath.section] ?: [self defaultBackgroundColorForIndexPath:indexPath];
	cell.label.text = [self.gridDataSource valueForRow:indexPath.row column:indexPath.section];
	cell.label.font = [self.gridDataSource fontForRow:indexPath.row column:indexPath.section] ?: [self defaultFontForItemAtIndexPath:indexPath];
	return cell;
}

#pragma mark - Private

- (UIFont*)defaultFontForItemAtIndexPath:(NSIndexPath*)indexPath
{
	return [UIFont systemFontOfSize:12.0];
}

- (UIColor*)defaultBackgroundColorForIndexPath:(NSIndexPath*)indexPath
{
	return indexPath.row % 2 ? [UIColor whiteColor] : [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
}

@end
