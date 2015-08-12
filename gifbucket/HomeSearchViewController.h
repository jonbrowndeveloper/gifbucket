//
//  HomeSearchViewController.h
//  GIFBucket
//
//  Created by Brown, Jon on 8/27/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeSearchViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSURL *pulledURLString;
@property (strong, nonatomic) NSString *recievedSearchQueryString;
@property (strong, nonatomic) NSString *segueActivated;
@property (strong, nonatomic) NSArray *receivedArrayReduced;
@property (strong, nonatomic) NSArray *receivedArrayFull;
@property (weak, nonatomic) IBOutlet UICollectionView *searchCollectionView;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSString *downloadedString;


@end
