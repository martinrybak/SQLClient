//
//  MRGridCollectionViewLayout.m
//  SQLClient
//
//  Created by Martin Rybak on 11/4/16.
//  Copyright © 2016 Martin Rybak. All rights reserved.
//

#import "MRGridCollectionViewLayout.h"
#import "MRGridCollectionView.h"

NSString* const MRGridCollectionViewLayoutCell = @"MRGridCollectionViewLayoutCell";
CGFloat const MRGridCollectionViewLayoutCellHeight = 40.0;
CGFloat const MRGridCollectionViewLayoutCellWidth = 100.0;

@interface MRGridCollectionViewLayout ()

@property (strong, nonatomic) NSMutableDictionary* cache;

@end

@implementation MRGridCollectionViewLayout

#pragma mark - NSObject

- (instancetype)init
{
	if (self = [super init]) {
		_cache = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - UICollectionViewLayout

//Called with every scroll, bounds change, or rotation. If YES, results in a call to prepareLayout.
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	//Is this a real bounds change or just a scroll?
	if (!CGRectEqualToRect(newBounds, self.collectionView.bounds)) {
		[self reset];
	}
	return YES;
}

//Primary objective is to calculate an instance of UICollectionViewLayoutAttributes for every item in the layout.
- (void)prepareLayout
{
	//If cache is empty, recreate all layouts
	if (!self.cache.count) {
//		self.cache[STHorizonViewLayoutTimeBorder] = @[[self layoutForBottomTimeBorder]];
//		self.cache[STHorizonViewLayoutTeamBorder] = @[[self layoutForRightTeamBorder]];
//		self.cache[STHorizonViewLayoutCorner] = @[[self layoutForCorner]];
//		self.cache[STHorizonViewLayoutTimeLabel] = [self layoutsForTimeLabels];
//		self.cache[STHorizonViewLayoutTimeBackground] = @[[self layoutForTimeBackground]];
//		self.cache[STHorizonViewLayoutTeamIcon] = [self layoutsForTeamIcons];
//		self.cache[STHorizonViewLayoutTeamBackground] = [self layoutsForTeamBackgrounds];
		self.cache[MRGridCollectionViewLayoutCell] = [self layoutsForItems];
//		self.cache[STHorizonViewLayoutTempEvent] = [self layoutsForTempEvent];
//		self.cache[STHorizonViewLayoutDashedBox] = [self layoutsForDashedBox];
//		self.cache[STHorizonViewLayoutHourLine] = [self layoutsForHourLines];
//		self.cache[STHorizonViewLayoutRowBackground] = [self layoutsForRowBackgrounds];
//		self.cache[STHorizonViewLayoutCurrentTimeLineTop] = @[[self layoutForCurrentTimeLineTop]];
//		self.cache[STHorizonViewLayoutCurrentTimeLineBottom] = @[[self layoutForCurrentTimeLineBottom]];
//		self.cache[STHorizonViewLayoutCurrentTimeCircle] = @[[self layoutForCurrentTimeCircle]];
	}
	
	//Always update frames of "sticky" items
//	[self lockLayouts:self.cache[STHorizonViewLayoutTeamBorder] axis:UICollectionViewScrollDirectionHorizontal];
//	[self lockLayouts:self.cache[STHorizonViewLayoutTimeBorder] axis:UICollectionViewScrollDirectionVertical];
//	[self lockLayouts:self.cache[STHorizonViewLayoutCorner] axis:UICollectionViewScrollDirectionHorizontal];
//	[self lockLayouts:self.cache[STHorizonViewLayoutCorner] axis:UICollectionViewScrollDirectionVertical];
//	[self lockLayouts:self.cache[STHorizonViewLayoutTimeBackground] axis:UICollectionViewScrollDirectionVertical];
//	[self lockLayouts:self.cache[STHorizonViewLayoutTimeLabel] axis:UICollectionViewScrollDirectionVertical];
//	[self lockLayouts:self.cache[STHorizonViewLayoutTeamBackground] axis:UICollectionViewScrollDirectionHorizontal];
//	[self lockLayouts:self.cache[STHorizonViewLayoutTeamIcon] axis:UICollectionViewScrollDirectionHorizontal];
//	[self lockLayouts:self.cache[STHorizonViewLayoutCurrentTimeCircle] axis:UICollectionViewScrollDirectionVertical];
//	[self lockLayouts:self.cache[STHorizonViewLayoutCurrentTimeLineTop] axis:UICollectionViewScrollDirectionVertical];
//	[self lockLayouts:self.cache[STHorizonViewLayoutCurrentTimeLineBottom] axis:UICollectionViewScrollDirectionVertical];
}

//Called after prepareLayout to determine which items are visible in the given rect
- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray* output = [NSMutableArray array];
	for (NSString* kind in self.cache.allKeys) {
		for (UICollectionViewLayoutAttributes* attributes in self.cache[kind]) {
			if (CGRectIntersectsRect(attributes.frame, rect)) {
				[output addObject:attributes];
			}
		}
	}
	return [output copy];
}

- (id<MRGridCollectionViewDataSource>)dataSource
{
	return ((MRGridCollectionView*)self.collectionView).gridDataSource;
}

- (CGSize)collectionViewContentSize
{
	CGFloat width = [self.dataSource numberOfColumns] * MRGridCollectionViewLayoutCellWidth;
	CGFloat height = [self.dataSource numberOfRows] * MRGridCollectionViewLayoutCellHeight;
	return CGSizeMake(width, height);
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath
{
	return self.cache[MRGridCollectionViewLayoutCell][indexPath.row];
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForSupplementaryViewOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath
{
	return self.cache[kind][indexPath.row];
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForDecorationViewOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath
{
	return self.cache[kind][indexPath.row];
}

#pragma mark - Layouts

- (NSArray*)layoutsForItems
{
	NSMutableArray* output = [NSMutableArray array];
	for (NSUInteger row = 0; row < [self.dataSource numberOfRows]; row++) {
		for (NSUInteger column = 0; column < [self.dataSource numberOfColumns]; column++) {
			[output addObject:[self layoutForItemAtRow:row column:column]];
		}
	}
	return [output copy];
}

- (UICollectionViewLayoutAttributes*)layoutForItemAtRow:(NSUInteger)row column:(NSUInteger)column
{
	CGFloat x = (column * MRGridCollectionViewLayoutCellWidth) + column;
	CGFloat y = (row * MRGridCollectionViewLayoutCellHeight) + row;
	CGRect frame = CGRectMake(x, y, MRGridCollectionViewLayoutCellWidth, MRGridCollectionViewLayoutCellHeight);

	NSIndexPath* indexPath = [NSIndexPath indexPathForItem:row inSection:column];
	UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	attributes.frame = frame;
	return attributes;
}

#pragma mark - Private

- (void)reset
{
	[self.cache removeAllObjects];
//	[self.offsets removeAllObjects];
}

@end
