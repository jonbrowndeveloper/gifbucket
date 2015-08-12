//
//  BucketGifViewController.h
//  GIFBucket
//
//  Created by Brown, Jon on 7/21/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BucketGifViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSString *currentCategory;
@property (weak, nonatomic) IBOutlet UICollectionView *bucketCollectionView;


@property (nonatomic, retain) NSDictionary *categories;

@property (nonatomic, retain) NSArray *images;
@property (assign) float currentSliderValue;
@property  (nonatomic, strong) NSBlockOperation *blockOperation;

@property (nonatomic, strong) NSManagedObjectContext *collectionManagedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSIndexPath *currentlyTapped;
@property (nonatomic, retain) NSMutableArray *selectedGIFS;

@property (weak, nonatomic) IBOutlet UILabel *emptyBucketLabel;



@end
