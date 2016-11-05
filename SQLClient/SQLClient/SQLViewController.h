//
//  SQLViewController.h
//  SQLClient
//
//  Created by Martin Rybak on 10/14/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRGridCollectionView.h"
#import "SQLClient.h"

@interface SQLViewController : UIViewController <MRGridCollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet MRGridCollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinner;

@end