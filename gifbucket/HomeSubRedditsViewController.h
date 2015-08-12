//
//  HomeSubRedditsViewController.h
//  GIFBucket
//
//  Created by JB on 8/26/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeSubRedditsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *subReddits;
@property (weak, nonatomic) IBOutlet UITableView *subRedditsTableView;
@property (strong, nonatomic) NSManagedObjectContext *redditManagedObjectContext;
@property (strong, nonatomic) NSArray *redditFetchArray;
- (IBAction)addSubredditButton:(id)sender;

@property (nonatomic, retain) UITextField *alertTextField;

@end
