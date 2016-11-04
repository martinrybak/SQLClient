//
//  MRGridCollectionView.h
//  SQLClient
//
//  Created by Martin Rybak on 11/4/16.
//  Copyright © 2016 Martin Rybak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRGridCollectionViewLayout.h"

@protocol MRGridCollectionViewDataSource <NSObject>

- (NSUInteger)numberOfColumns;
- (NSUInteger)numberOfRows;
- (NSString*)titleForColumn:(NSUInteger)column;
- (id)valueForRow:(NSUInteger)row column:(NSUInteger)column;

@end

@interface MRGridCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) MRGridCollectionViewLayout* layout;
@property (weak, nonatomic) NSObject<MRGridCollectionViewDataSource>* gridDataSource;

@end
