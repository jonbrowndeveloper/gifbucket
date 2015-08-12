//
//  HomeViewController.m
//  GIFBucket
//
//  Created by JB on 6/12/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "GBGIFImage.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "HomeSearchViewController.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "APActivityProvider.h"
#import "ImportToCategoryViewController.h"
#import "BucketGIFImageViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize homeManagedObjectContext = _homeManagedObjectContext, homeCollectionView, recentImages, filePath, categoryFetchArray, poweredByGiphyOutlet, noGifsLabel, searchString, homeSearchBar, recentGifsLabel, recentImagesURLs, arrowImageView, importHelpArrowImageView, importHelpButtonOutlet, searchWebHelpButtonOutlet, searchHelpArrowImageView, subredditHelpButtonOutlet, subredditHelpArrowImageView, gifBucketLogoImageView, isCampaignMessage, reviewReminder, reviewMessageSeen;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewWillAppear:(BOOL)animated
{
    // RELOAD DATA HERE
    
    if (_homeManagedObjectContext == nil)
    {
        _homeManagedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
    }
    
    
    // get number of sent gifs through campaign
    NSString *numberOfGifsSent = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfSentGifs"];
    long i = numberOfGifsSent.integerValue;
    
    if (i == 5 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"thankYouMessageComplete"])
    {
        UIAlertView *noResults = [[UIAlertView alloc] initWithTitle:@"Thanks for spreading\nthe word!" message:@"\n+ 5 space has been added to any bucket you create or currently have " delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noResults.alertViewStyle = UIAlertViewStyleDefault;
        
        [noResults show];
        
        BOOL stopMessaging = YES;
        BOOL stopCampaign = NO;
        [[NSUserDefaults standardUserDefaults] setBool:stopMessaging forKey:@"thankYouMessageComplete"];
        
        [[NSUserDefaults standardUserDefaults] setBool:stopMessaging forKey:@"bucketViewRefreshed"];
        
        [[NSUserDefaults standardUserDefaults] setBool:stopMessaging forKey:@"bucketAreLarger"];
        
        [[NSUserDefaults standardUserDefaults] setBool:stopCampaign forKey:@"campaignOn"];
    }
    
    // get number of gifs imported overall to send app store review reminder
    
    // get number of sent gifs through campaign
    NSString *numberOfImports = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImports"];
    long imports = numberOfImports.integerValue;

    if (imports !=0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"hitRemindMeLater"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"completedReview"])
    {
        
    
        if (imports == 7 || imports == 16 || imports == 25)
        {
            reviewReminder = @"YES";
            
            // if mis-formatted string, display new alert view with instructions
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Would you like to\nreview Gif Bucket?" message:nil delegate:self cancelButtonTitle:@"No, I don't love Gif Bucket" otherButtonTitles:@"Yes Please", @"Maybe Later...", nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
            [alert show];
        }
        
    }
    
    // send to bucket controller to make bucket if first time
    

    // make sure progress view isn't showing
    
    [SVProgressHUD dismiss];
    
    // show title
    
    UIImage *image = [UIImage imageNamed:@"gifbucket-title-height45.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:image];
    
    UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithCustomView:logoImageView];
    [self.navigationItem setLeftBarButtonItem:logoItem animated:NO];
    
    // hide toolbar when coming from gif detail view
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    // setup fetch request for category names
    
    NSFetchRequest *categoryRequest = [NSFetchRequest fetchRequestWithEntityName:@"GBCategory"];
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"GBCategory" inManagedObjectContext:_homeManagedObjectContext];
    categoryRequest.resultType = NSDictionaryResultType;
    categoryRequest.propertiesToFetch = [NSArray arrayWithObjects:[[categoryEntity propertiesByName] objectForKey:@"categoryName"], nil];
    categoryRequest.returnsDistinctResults = YES;
    
    self.categoryFetchArray = [_homeManagedObjectContext executeFetchRequest:categoryRequest error:nil];
    
    // set request to get recent image names
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GBGIFImage"];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:_homeManagedObjectContext];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = [NSArray arrayWithObjects:[[entity propertiesByName] objectForKey:@"imageName"], nil];
    
    // set request to get image URLs
    
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"GBGIFImage"];
    
    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:_homeManagedObjectContext];
    request2.resultType = NSDictionaryResultType;
    request2.propertiesToFetch = [NSArray arrayWithObjects:[[entity2 propertiesByName] objectForKey:@"imageURL"], nil];
    
    // setup request to filter out most recent 6 gifs
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    request.returnsDistinctResults = YES;
    [request2 setSortDescriptors:sortDescriptors];
    request2.returnsDistinctResults = YES;
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen
        [request setFetchLimit:6];
    } else {
        // This is other iPhone
        [request setFetchLimit:9];
        
    }
    
    // hide help views - currently not implemented at all...
    
    subredditHelpButtonOutlet.hidden = YES;
    subredditHelpArrowImageView.hidden = YES;
    searchWebHelpButtonOutlet.hidden = YES;
    searchHelpArrowImageView.hidden = YES;
    importHelpButtonOutlet.hidden = YES;
    importHelpArrowImageView.hidden = YES;
    
    // save most recents to gif array
    
    NSError *error = nil;
    recentImages = [context executeFetchRequest:request error:&error];
    recentImagesURLs = [context executeFetchRequest:request2 error:&error];
    // NSLog(@"Recent URLs %@", recentImagesURLs);
    // NSLog(@"recent images: %@", recentImages);
    
    // show warning label if no gifs
    
    if (categoryFetchArray.count == 0)
    {
        arrowImageView.image = [UIImage imageNamed:@"gifbucket-uploadicon-flipped-blue60.png"];
        arrowImageView.alpha = 0.5;
        arrowImageView.hidden = YES;
        noGifsLabel.hidden = NO;
        recentGifsLabel.hidden = YES;
        noGifsLabel.text = @"Get started by creating a new bucket!";
        noGifsLabel.textColor = [UIColor grayColor];
        
        
        for (int i = 2; i <= 62; i++)
        {
            [NSTimer scheduledTimerWithTimeInterval:i target:self selector:@selector(animateHelpImageView) userInfo:nil repeats:NO];
            i = i + 9;
        }

        gifBucketLogoImageView.hidden = YES;
        subredditHelpButtonOutlet.hidden = YES;
        subredditHelpArrowImageView.hidden = YES;
        searchWebHelpButtonOutlet.hidden = YES;
        searchHelpArrowImageView.hidden = YES;
        importHelpButtonOutlet.hidden = YES;
        importHelpArrowImageView.hidden = YES;
        
    }
    
    else if (recentImages.count == 0 && categoryFetchArray.count != 0)
    {
        /*
        subredditHelpButtonOutlet.hidden = NO;
        subredditHelpArrowImageView.alpha = 0.0;
        searchWebHelpButtonOutlet.hidden = NO;
        searchHelpArrowImageView.alpha = 0.0;
        // searchHelpArrowImageView.hidden = NO;
        importHelpButtonOutlet.hidden = NO;
        importHelpArrowImageView.alpha = 0.0;
        // importHelpArrowImageView.hidden = NO;
        
        subredditHelpArrowImageView.image = [UIImage imageNamed:@"gifbucket-uploadicon-flipped-blue60.png"];
        searchHelpArrowImageView.image = [UIImage imageNamed:@"gifbucket-uploadicon-blue60.png"];
        importHelpArrowImageView.image = [UIImage imageNamed:@"gifbucket-uploadicon-blue60.png"];
        */
        
        
        gifBucketLogoImageView.alpha = 0.6;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
        {
            gifBucketLogoImageView.image = [UIImage imageNamed:@"gifbucketicon-infinite200.png"];
        }
        else
        {
            gifBucketLogoImageView.image = [UIImage imageNamed:@"gifbucketicon-noshadow200.png"];
        }

        gifBucketLogoImageView.hidden = NO;
        arrowImageView.hidden = YES;
        recentGifsLabel.hidden = YES;
        noGifsLabel.hidden = NO;
        noGifsLabel.text = @"";
        noGifsLabel.textColor = [UIColor grayColor];
    }
    
    else if (categoryFetchArray.count != 0 && recentImages.count != 0)
    {
        gifBucketLogoImageView.hidden = YES;
        arrowImageView.hidden = YES;
        noGifsLabel.hidden = YES;
        recentGifsLabel.hidden = NO;
    }

    
    [homeCollectionView reloadData];
}

- (void)animateHelpImageView
{
    [self animateHelpArrow:arrowImageView isUP:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"app delegate url = %@",[appDelegate receivedGIFURL]);
    
    if ([appDelegate receivedGIFURL] != nil || [[NSUserDefaults standardUserDefaults] boolForKey:@"importingFromOtherApp"])
    {
        BOOL reviewNotice = NO;
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"importingFromOtherApp"];
        
        NSLog(@"importing from another app");
        
        [self performSelector:@selector(barButtonImport:) withObject:self];
    }
    */
    
    reviewMessageSeen = @"NO";
    
    // setup promotion to send gifs to friends
    
    // get number of imports
    NSString *numberOfImports = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImports"];
    NSLog(@"current maximum: %@", numberOfImports);
    long i = numberOfImports.integerValue;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"bucketAreLarger"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"] && i == 2 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"campaignOn"])
    {
        isCampaignMessage = @"YES";
        
        // if mis-formatted string, display new alert view with instructions
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Spread the word and get more space!" message:@"\nSend a gif in 5 different texts, posts, or emails to your friends and get + 5 space for gifs in every bucket" delegate:self cancelButtonTitle:@"Yes!" otherButtonTitles:@"Maybe Later...", nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
        [alert show];
        
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"bucketAreLarger"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"] && i == 5 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"campaignOn"])
    {
        isCampaignMessage = @"YES";
        
        // if mis-formatted string, display new alert view with instructions
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Spread the word and get more space!" message:@"\nSend a gif in 5 different texts, posts, or emails to your friends and get + 5 space for gifs in every bucket" delegate:self cancelButtonTitle:@"Yes!" otherButtonTitles:@"Maybe Later...", nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
        [alert show];
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"bucketAreLarger"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"] && i == 10 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"campaignOn"])
    {
        isCampaignMessage = @"YES";
        
        // if mis-formatted string, display new alert view with instructions
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Spread the word and get more space!" message:@"\nSend a gif in 5 different texts, posts, or emails to your friends and get + 5 space for gifs in every bucket" delegate:self cancelButtonTitle:@"Yes!" otherButtonTitles:@"Don't remind me again", nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
        [alert show];
    }
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen
        CGRect oldFrame = gifBucketLogoImageView.frame;
        CGRect newFrame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y -	 50, oldFrame.size.width, oldFrame.size.height);
        gifBucketLogoImageView.frame = newFrame;
    } else {
        // This is other iPhone
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTime"])
    {
        [self.tabBarController setSelectedIndex:1];
    }
    
    // pasteboard = [UIPasteboard generalPasteboard];
    
    homeCollectionView.backgroundColor = [UIColor whiteColor];
    
    // set text of uinavbar and color
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:6.0/255.0 green:79.0/255.0 blue:134.0/255.0 alpha:1]];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // setup powered by Giphy logo
    
    NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:@"API_Larger_Grey_Trans_BG_once" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:bundleFilePath];
    
    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:gifData];
    FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
    theImageView.animatedImage = image;
    
    theImageView.frame = CGRectMake(0.0, 0.0, 73.0, 27.0);
    
    [poweredByGiphyOutlet addSubview:theImageView];
    
    // add tap gesture to get rid of keyboard when any part of view is touched
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    
    [self.view addGestureRecognizer:tap];
}

// may need to implement auto rotation at some point just for a single window
// but it turns out to be buggy

/*
- (BOOL)shouldAutorotate { return NO; }

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}*/

-(void)dismissKeyboard
{
    [homeSearchBar resignFirstResponder];
}

#pragma mark -- clearing up memeory

// unfortuantely the FLAnimatedImage API does not work well with Garbage Collector, so manual memory management is needed

// clear up data from collection view to free up memory

- (void)viewWillDisappear:(BOOL)animated
{
    for (UICollectionViewCell *cell in [self.homeCollectionView visibleCells])
    {
        // remove subviews from cells to free up memory
        [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [poweredByGiphyOutlet.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark -- collection view methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return recentImages.count;
    // return the number of gifs from the fetched results
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // setup home collection view cell
    static NSString *CellIdentifier = @"HomeCVC";
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    // remove whatever subviews are currently store to free up memory
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Load GIF from file
    
    NSString *currentGIFDictionary = recentImages[indexPath.row];
    NSString *currentGIFImage = [currentGIFDictionary valueForKey:@"imageName"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsDirectoryFull = [documentsDirectory stringByAppendingString:@"/"];

    filePath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.gif",currentGIFImage]];
    
    // load data into Home Collection View Cell ImageView
    
    NSData *gifData = [NSData dataWithContentsOfFile:filePath];
    
    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:gifData];
    FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
    theImageView.animatedImage = image;
    theImageView.frame = CGRectMake(0.0, 0.0, 90.0, 90.0);
    [cell addSubview:theImageView];
    
    image = nil;
    
    return cell;
}

#pragma mark -- search bar

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // remove keyboard when text editing finishes
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // remove keyboard when cancel button clicked
    [searchBar resignFirstResponder];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isCampaignMessage = @"NO";
    reviewReminder = @"NO";
    
    // setup network reliability
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    
    // this appears to work TOO well
    // Reachability *giphyReachability = [Reachability reachabilityWithHostName:@"http://www.giphy.com"];
    // NetworkStatus giphyNetworkStatus = [giphyReachability currentReachabilityStatus];
    
    // end editing and rmeove keyboard
    [self.view endEditing:YES];
    [searchBar resignFirstResponder];
    
    if (networkStatus == ReachableViaWWAN)
    {
        [SVProgressHUD showWithStatus:@"You are not on WiFi. This may take a while"];
    }
    
    NSString *searchStringTemp = searchBar.text;
    searchString = [searchStringTemp stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *quickArray = [appDelegate prohibitedSearchWords];
    
    
    NSMutableArray *parts = [NSMutableArray arrayWithArray:[searchStringTemp componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    // NSLog(@"parts %@", parts);
    
    NSUInteger barIndex = NSNotFound;
    
    for (int i = 0; i < parts.count; i++)
    {
        barIndex = [quickArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj caseInsensitiveCompare:parts[i]] == NSOrderedSame) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
    }
    
    // check if there are no buckets and network connectivity
    if ([categoryFetchArray count] == 0)
    {
        [SVProgressHUD dismiss];
        
        [self.tabBarController setSelectedIndex:1];
    }
    else if (networkStatus == NotReachable)
    {
        UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"Make sure you have a stable internet connection" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noConnectionAlert.alertViewStyle = UIAlertViewStyleDefault;
        
        [noConnectionAlert show];
        [SVProgressHUD dismiss];
    }
    else if (barIndex != NSNotFound)
    {

        
        UIAlertView *noResults = [[UIAlertView alloc] initWithTitle:@"No search results" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noResults.alertViewStyle = UIAlertViewStyleDefault;
        
        [noResults show];
        [SVProgressHUD dismiss];
    }
    else
    {
        // if there is a bucket send to search results controller
        [self performSegueWithIdentifier:@"toGIPHY" sender:self];
    }
    
}

// segue to search controller with string

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"recentToDetail"])
    {
        UICollectionViewCell *cell = (UICollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.homeCollectionView indexPathForCell:cell];
        
        // NSLog(@"index path: %@", indexPath);
        
        // send selected image name to next controller
        
        BucketGIFImageViewController *divc = (BucketGIFImageViewController *)[segue destinationViewController];
        NSString *gifName = recentImages[indexPath.row];
        NSString *gifNameActual = [gifName valueForKey:@"imageName"];
        divc.currentGIFImage = gifNameActual;
        
        NSLog(@"current image name: %@", gifNameActual);
    }
    
    if([segue.identifier isEqualToString:@"toGIPHY"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setSearchString:searchString];
        
    }
}

- (IBAction)barButtonImport:(id)sender
{
    // NSString *poop = @"poop.gif";
    // NSURL *poopURL = [NSURL URLWithString:poop];
    // pasteboard.URL = poopURL;
    
    pasteboard = [UIPasteboard generalPasteboard];
    NSUInteger count = [categoryFetchArray count];
    
    // NSLog(@"pasteboard has: %@", [UIPasteboard generalPasteboard].URL);
    
    // verify that there is an image to paste in the clipboard and there is a bucket to import to
    
    if (count == 0)
    {
        [self.tabBarController setSelectedIndex:1];
    }
    else
    {
        // send to import view controller
        
        [self performSegueWithIdentifier:@"toImport" sender:self];
    }
}

#pragma mark -- help tutorial (currently not implemented)

// - (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock

- (void)animateHelpArrow:(UIImageView *)imageView isUP:(BOOL)isUP
{
    int orientation;
    if (isUP == YES) {
        orientation = -10;
    }
    else
    {
        orientation = 10;
    }
    imageView.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        // fade in
        imageView.alpha = 0.7f;
    } completion:nil];
    
    // [imageView setAlpha:0.7];
    
    
    [UIView animateKeyframesWithDuration:1.0 delay:0.3 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            imageView.center = CGPointMake(imageView.center.x, imageView.center.y - orientation);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            imageView.center = CGPointMake(imageView.center.x, imageView.center.y + orientation);
            
        }];
    } completion:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fadeOutImageView) userInfo:nil repeats:NO];

}

-(void)fadeOutImageView
{
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        importHelpArrowImageView.alpha = 0.0f;
        searchHelpArrowImageView.alpha = 0.0f;
        subredditHelpArrowImageView.alpha = 0.0f;
        arrowImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        importHelpArrowImageView.hidden = NO;
        searchHelpArrowImageView.hidden = NO;
        subredditHelpArrowImageView.hidden = NO;
        arrowImageView.hidden = NO;
    }];
}
- (IBAction)searchWebHelpButton:(id)sender
{
    importHelpArrowImageView.hidden = YES;
    subredditHelpArrowImageView.hidden = YES;

    [self animateHelpArrow:searchHelpArrowImageView isUP:NO];

}

- (IBAction)subredditHelpButton:(id)sender
{
    importHelpArrowImageView.hidden = YES;
    searchHelpArrowImageView.hidden = YES;
    

    [self animateHelpArrow:subredditHelpArrowImageView isUP:YES];

    
}

- (IBAction)importHelpButton:(id)sender
{
    searchHelpArrowImageView.hidden = YES;
    subredditHelpArrowImageView.hidden = YES;
    

    [self animateHelpArrow:importHelpArrowImageView isUP:NO];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0 && [isCampaignMessage isEqualToString:@"YES"])
    {
        NSLog(@"campaign start");
        BOOL campaignOn = YES;
        [[NSUserDefaults standardUserDefaults] setBool:campaignOn forKey:@"campaignOn"];
        
        UIAlertView *noResults = [[UIAlertView alloc] initWithTitle:@"Here's how:" message:@"\nTap a gif and press the Action button on the bottom right.\nSend that to a friend via text, facebook, twitter, email, etc!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noResults.alertViewStyle = UIAlertViewStyleDefault;
        
        [noResults show];
        
        isCampaignMessage = @"NO";
    }
    if(buttonIndex == 1 && [reviewReminder isEqualToString:@"YES"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=918210585"]];
        
        reviewReminder = @"NO";
        
        BOOL campaignOn = YES;
        [[NSUserDefaults standardUserDefaults] setBool:campaignOn forKey:@"completedReview"];
    }
    else if(buttonIndex == 2 && [reviewReminder isEqualToString:@"YES"])
    {
        BOOL campaignOn = YES;
        [[NSUserDefaults standardUserDefaults] setBool:campaignOn forKey:@"hitRemindMeLater"];
        
        NSLog(@"'Maybe later' has been pressed");
    }
    else if(buttonIndex == 2 && [reviewReminder isEqualToString:@"YES"])
    {
        
        NSLog(@"i don't love gif bucket pressed");
        
        BOOL campaignOn = YES;
        [[NSUserDefaults standardUserDefaults] setBool:campaignOn forKey:@"completedReview"];
    }
}

@end
