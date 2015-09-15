//
//  HomeViewController.h
//  GIFBucket
//
//  Created by JB on 6/12/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
{
    UIPasteboard *pasteboard;
}
// core data
@property (nonatomic, strong) NSManagedObjectContext *homeManagedObjectContext;
@property (strong, nonatomic) IBOutlet UICollectionView *homeCollectionView;

// gif database arrays
@property (strong, nonatomic) NSArray *recentImages;
@property (strong, nonatomic) NSArray *recentImagesURLs;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSArray *categoryFetchArray;
// update 1.2 review and campaign strings
@property (strong, nonatomic) NSString *isCampaignMessage;
@property (strong, nonatomic) NSString *reviewReminder;
@property (strong, nonatomic) NSString *reviewMessageSeen;

// giphy search and gif
@property (weak, nonatomic) IBOutlet UIImageView *poweredByGiphyOutlet;
@property (weak, nonatomic) IBOutlet UILabel *noGifsLabel;
@property (strong, nonatomic) NSString *searchString;
@property (weak, nonatomic) IBOutlet UISearchBar *homeSearchBar;
- (IBAction)barButtonImport:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *recentGifsLabel;

// tutorial stuff - not currently implemented
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *importHelpArrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *searchHelpArrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *subredditHelpArrowImageView;

// old search 
@property (weak, nonatomic) IBOutlet UIButton *searchWebHelpButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *subredditHelpButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *importHelpButtonOutlet;

- (IBAction)searchWebHelpButton:(id)sender;
- (IBAction)subredditHelpButton:(id)sender;
- (IBAction)importHelpButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *gifBucketLogoImageView;




@end
