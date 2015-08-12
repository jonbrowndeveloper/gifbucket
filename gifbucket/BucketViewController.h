//
//  BucketViewController.h
//  GIFBucket
//
//  Created by JB on 7/21/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

@interface BucketViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *bucketTableView;
- (IBAction)addButton:(id)sender;

@property (nonatomic, retain) UITextField *alertTextField;

//core data
@property (nonatomic, strong) NSManagedObjectContext *bucketManagedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIButton *segueOnlyButton;
@property (nonatomic) NSInteger numberOfBuckets;

@end
