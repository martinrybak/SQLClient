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

@optional

- (UIFont*)fontForRow:(NSUInteger)row column:(NSUInteger)column;
- (UIColor*)fontColorForRow:(NSUInteger)row column:(NSUInteger)column;
- (UIColor*)backgroundColorForRow:(NSUInteger)row column:(NSUInteger)column;

@end

@interface MRGridCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet NSObject<MRGridCollectionViewDataSource>* gridDataSource;

@end
