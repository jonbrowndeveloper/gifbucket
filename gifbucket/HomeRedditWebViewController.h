//
//  HomeRedditWebViewController.h
//  GIFBucket
//
//  Created by JB on 8/26/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeRedditWebViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

// passed in current subreddit
@property (strong, nonatomic) NSString *currentSubReddit;

// reddit urls for gifs given by json
@property (strong, nonatomic) NSString *pulledStringReddit;
@property (strong, nonatomic) NSURL *pulledURLStringReddit;

@property (strong, nonatomic) NSMutableArray *receivedGifUrls;
@property (strong, nonatomic) NSMutableArray *receivedPostTitles;
@property (strong, nonatomic) NSArray *receivedPostOverEighteen;
@property (strong, nonatomic) NSMutableArray *gifvDownloadLinkList;

@property (weak, nonatomic) IBOutlet UITableView *subredditResultsTableView;


@end
