//
//  NewBucketViewController.h
//  GIFBucket
//
//  Created by JB on 9/14/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewBucketViewController : UIViewController

@property (nonatomic, strong) NSArray *fetchedCategoryArray;
@property (nonatomic, strong) NSArray *productsArray;

@property (weak, nonatomic) IBOutlet UIImageView *thankYouImageView;

@property (strong, nonatomic) NSArray *prices;
@property (strong, nonatomic) NSArray *productTitles;
@property (strong, nonatomic) NSArray *productDescriptions;
@property (strong, nonatomic) NSArray *pictureNames;

@property (weak, nonatomic) IBOutlet UITableView *productsTableView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfBucketsAvailibleLabel;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
- (IBAction)restoreButtonAction:(id)sender;

@property NSTimer *timer;

@end
