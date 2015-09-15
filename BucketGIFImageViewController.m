//
//  BucketGIFImageViewController.m
//  GIFBucket
//
//  Created by Brown, Jon on 8/25/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "BucketGIFImageViewController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "GBGIFImage.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "APActivityProvider.h"
#import "DebugView.h"
#import "BucketViewController.h"
#import "GifBucketIAPHelper.h"

@interface BucketGIFImageViewController ()

@property (nonatomic, strong) FLAnimatedImage *image;
@property (nonatomic, strong) __block NSArray *productsArray;
@property (nonatomic, strong) NSString *tapToggle;
@property (nonatomic, strong) UIImageView *playButton;
@property (nonatomic, strong) UIImageView *pauseButton;
@property (nonatomic, strong) NSString *comingFromUnlimited;

@end

@implementation BucketGIFImageViewController

@synthesize currentGIFImage, fileURL, filePath, freeGameButtonOutlet, removeAdsButtonOutlet;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

// selector to tell AppDelegate that this view should rotate
// - (void)canRotate { }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get some stuff ready before showing the gif image
    
    NSArray *arr = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsUrl = [arr firstObject];
    NSURL *fullURL = [documentsUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif", currentGIFImage]];
    
    // display the animated image
    
    self.image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:fullURL]];
    self.gifImageView.animatedImage = self.image;
    NSLog(@"gif image:%@", self.image);
    
    NSLog(@"width: %f\nheight: %f", self.gifImageView.frame.size.width, self.gifImageView.frame.size.width);
    
    self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.gifImageView.userInteractionEnabled = YES;
    
    // setup play and pause buttons
    
    UIImage *playImage = [UIImage imageNamed:@"Play-icon120.png"];
    self.playButton = [[UIImageView alloc] initWithImage:playImage];
    
    self.playButton.hidden = YES;
    
    UIImage *pauseImage = [UIImage imageNamed:@"Pause-icon120.png"];
    self.pauseButton = [[UIImageView alloc] initWithImage:pauseImage];
    
    self.pauseButton.hidden = YES;
    
    [self sizePauseAndPlay];
    
    // set timer to hide play button after 2 seconds
    
    self.tapToggle = @"0";
    
    // self.gifImageView = [[FLAnimatedImageView alloc] init];

    // tap recognizer for play/pause button on gif image view
    
    UITapGestureRecognizer *tapGifImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    tapGifImageView.numberOfTapsRequired = 1;
    tapGifImageView.numberOfTouchesRequired = 1;
    [self.gifImageView addGestureRecognizer:tapGifImageView];
    // [self.pauseButton addGestureRecognizer:tapGifImageView];
    // [self.playButton addGestureRecognizer:tapGifImageView];
    [self.gifImageView setUserInteractionEnabled:YES];
    [self.playButton setUserInteractionEnabled:YES];
    [self.pauseButton setUserInteractionEnabled:YES];
    
    // buy and add button configue look / location
    
    CALayer *btnLayer = [freeGameButtonOutlet layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1].CGColor];
    [btnLayer setCornerRadius:8.0f];
    [btnLayer setBackgroundColor:[UIColor whiteColor].CGColor];

    CALayer *btnLayer2 = [removeAdsButtonOutlet layer];
    [btnLayer2 setMasksToBounds:YES];
    [btnLayer2 setBorderWidth:1.0f];
    [btnLayer2 setBorderColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1].CGColor];
    [btnLayer2 setCornerRadius:8.0f];
    [btnLayer2 setBackgroundColor:[UIColor whiteColor].CGColor];
    
    // get file path for deletion
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsDirectoryFull = [documentsDirectory stringByAppendingString:@"/"];
    
    filePath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.gif",currentGIFImage]];
    
    // initiate bar buttons
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    
    // customer copy button
    
    UIImage *background = [UIImage imageNamed:@"copyIcon-blue-solid-25.png"];
    UIImage *backgroundSelected = [UIImage imageNamed:@"copyIcon-blue-alpha-25.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(copyToClipboard) forControlEvents:UIControlEventTouchUpInside]; //adding action
    [button setBackgroundImage:background forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundSelected forState:UIControlStateSelected];
    button.frame = CGRectMake(0 ,0,25,25);
    button.tintColor = [UIColor colorWithRed:0.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    UIBarButtonItem *copyButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *middleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashButton:)];
    
    [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
    NSArray *toolbarItems = [NSArray arrayWithObjects:trashButton, middleSpace, copyButton,fixedSpace, actionButton, nil];
    
    [self setToolbarItems:toolbarItems animated:YES];
    
    NSInteger i = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfLaunches"];
    NSLog(@"Launch number is %ld", (long)i);
    
    NSString *numberOfImports = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImports"];
    NSLog(@"current maximum: %@", numberOfImports);
    long numberOfImportsInteger = numberOfImports.integerValue;
    
    // detect device rotation
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
    
    if (i > 1 || [[NSUserDefaults standardUserDefaults] boolForKey:@"fromOlderVersion1.1"])
    {
        if(numberOfImportsInteger == 1 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"helperShown"])
        {
            
            UIAlertView *noResults = [[UIAlertView alloc] initWithTitle:@"Did you know..." message:@"\nTap on a gif to Pause it,\ntap to start again\n-AND-\nFlip your phone sideways\nto view gifs in landscape!" delegate:self cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
            noResults.alertViewStyle = UIAlertViewStyleDefault;
            
            [noResults show];
            // turn off helper
            BOOL reviewNotice = YES;
            [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"helperShown"];
        }
        
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"restartMessageSeen"])
        {
            // do nothing
        }
        else if  (numberOfImportsInteger > 6)
        {
            /*
            [SVProgressHUD showSuccessWithStatus:@"A new landscape mode has been added to Gif Bucket for viewing gifs!\nRestart the app once to enable this function."];
            */
            
            
            NSLog(@"message will no longer be seen");
            BOOL messageSeen = YES;
            [[NSUserDefaults standardUserDefaults] setBool:messageSeen forKey:@"restartMessageSeen"];
             
            
            [[NSUserDefaults standardUserDefaults] synchronize];

        }
        // [SVProgressHUD showSuccessWithStatus:@"A new landscape mode has been added to Gif Bucket for viewing gifs!\nRestart the app once to enable this function."];
    }
    
    NSString *numberOfViews = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfTimeGifViewLoaded"];
    NSLog(@"current maximum: %@", numberOfViews);
    long numberOfViewsLong = numberOfViews.integerValue;
    
    if (numberOfViewsLong != 0 && numberOfViewsLong % 3 == 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"campaignOn"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        NSLog(@"checking for ad");
        if ([AppsfireAdSDK isThereAModalAdAvailableForType:AFAdSDKModalTypeUraMaki] == AFAdSDKAdAvailabilityYes) {
            NSLog(@"requesting ad...");
            // request ad
            [AppsfireAdSDK requestModalAd:AFAdSDKModalTypeUraMaki withController:[UIApplication sharedApplication].keyWindow.rootViewController withDelegate:nil];
            
        }
    }
    
    // increase the number of times this view has been seen
    numberOfViewsLong = numberOfViewsLong + 1;
    
    NSString *newNumberOfViews = [NSString stringWithFormat:@"%ld", numberOfViewsLong];
    // NSLog(@"new view #: %@", newNumberOfViews);
    
    [[NSUserDefaults standardUserDefaults] setObject:newNumberOfViews forKey:@"numberOfTimeGifViewLoaded"];
    
}

- (void) didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            [self sizePauseAndPlay];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self sizePauseAndPlay];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self sizePauseAndPlay];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self sizePauseAndPlay];
            break;
            
        default:
            break;
    }
}

- (void)sizePauseAndPlay
{
    CGRect newFrame2 = CGRectMake((([[UIScreen mainScreen] applicationFrame].size.width)/2)-60, (([[UIScreen mainScreen] applicationFrame].size.height)/2)-100, 120, 120);
    self.pauseButton.frame = newFrame2;
    self.playButton.frame = newFrame2;
}




- (BOOL) hidesBottomBarWhenPushed
{
    return (self.navigationController.topViewController == self);
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"adsRemoved"])
    {
        // [adView removeFromSuperview];
        removeAdsButtonOutlet.hidden = YES;
        freeGameButtonOutlet.hidden = YES;
        
    }
    
    // [self.gifImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // show bottom toolbar
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // self.tabBarController.tabBar.hidden = NO;
    self.gifImageView.animatedImage = nil;
    self.image = nil;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

- (IBAction)actionButtonPressed:(id)sender
{
    // show progress bar when loading activity view for the first time
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setIsBeingCopied:@"NO"];

    
        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        APActivityProvider *activityProvider = [[APActivityProvider alloc] init];
            
        NSError *error = nil;
        
        GBGIFImage *newGBGIF = nil;
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:context]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"imageName ==  %@",currentGIFImage]];
        
        newGBGIF = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
            
        [appDelegate setCurrentGifURLString:[newGBGIF valueForKey:@"imageURL"]];
            NSLog(@"gif url = %@", [appDelegate currentGifURLString]);
        
        // Edit the Time Stamp information for the GIF
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        [newGBGIF setValue:dateString forKey:@"timeStamp"];
        
        error = nil;
        [context save:&error];
        
        // Set activity view controller and send gif data
        
        NSString *textToShare = @"from Gif Bucket";
            
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"campaignOn"] )
        {
            textToShare = @"Sent this from Gif Bucket\n\nhttps://itunes.apple.com/us/app/gif-bucket/id918210585?ls=1&mt=8";
            
            // add to number of sent gifs
        }

        
        NSData *quickGIFData = [[NSData alloc] initWithContentsOfFile:filePath];
    
        NSArray *objectsToShare = @[quickGIFData, activityProvider, textToShare];
        // NSLog(@"objects to share are: %@", objectsToShare);
    
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        NSArray *excludedActivities = @[UIActivityTypeAirDrop,
                                        UIActivityTypePrint,
                                        UIActivityTypeAssignToContact,
                                        UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypePostToFlickr,
                                        UIActivityTypeAddToReadingList,
                                        UIActivityTypePostToVimeo,
                                        UIActivityTypeCopyToPasteboard];
        
        activityViewController.excludedActivityTypes = excludedActivities;
        
        [self presentViewController:activityViewController animated:YES completion:nil];

            
            [appDelegate setIsBeingCopied:@"NO"];
            [appDelegate setActivityViewActivated:@"YES"];
        
            dispatch_async(dispatch_get_main_queue(), ^{
            // [self performSelector:@selector(showGifImage) withObject:self];
            [SVProgressHUD dismiss];
            
         });
    });
    NSLog(@"gif should be copied is: %@", appDelegate.isBeingCopied);
}

- (void)copyToClipboard
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
    GBGIFImage *newGBGIF = nil;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"imageName ==  %@",currentGIFImage]];
    
    newGBGIF = [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    
    NSString *clipboardString = [newGBGIF valueForKey:@"imageURL"];
    
    if(clipboardString == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"Unable to copy gif link!\nThere is no link to copy since it was copied directly to\nGif Bucket."];
    }
    else
    {
        pasteboard.string = [newGBGIF valueForKey:@"imageURL"];
        NSLog(@"image url copied to clipboard with url: %@", [newGBGIF valueForKey:@"imageURL"]);
        
        [SVProgressHUD showSuccessWithStatus:@"gif link copied!"];
    }


}

- (IBAction)trashButton:(id)sender
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"imageName ==  %@",currentGIFImage]];
    
    NSError *error = nil;
   
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    // get full documents directory for gif file deletion
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsDirectoryFull = [documentsDirectory stringByAppendingString:@"/"];
    
    // setup quick file manager
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // delete both gif image entity, gif, and png image
    
    for (GBGIFImage * GBGIFImage in results)
    {
        // get both PNG and GIF file names
        
        NSString *gifName = [GBGIFImage imageName];
        NSString *fullGIFPath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.gif", gifName]];
        NSString *fullPNGPath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.png", gifName]];
        
        // delete files
        
        [fileManager removeItemAtPath:fullGIFPath error:nil];
        [fileManager removeItemAtPath:fullPNGPath error:nil];
        
        [context deleteObject:GBGIFImage];
    }
    
    NSError *saveError = nil;
    [context save:&saveError];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.tapToggle isEqualToString:@"1"])
    {
        self.playButton.hidden = NO;
        self.pauseButton.hidden = YES;
        [self.view insertSubview:self.playButton aboveSubview:self.gifImageView];
        self.playButton.alpha = 0.7f;
        [UIView animateWithDuration:1.0 animations:^(void){
            self.playButton.alpha = 0.0f;
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(removePlayButtonFromView) userInfo: nil repeats: NO];
        }];
        [self.gifImageView startAnimating];
        self.tapToggle = @"0";
        
    }
    else if ([self.tapToggle isEqualToString:@"0"])
    {
        self.pauseButton.hidden = NO;
        self.playButton.hidden = YES;
        [self.view insertSubview:self.pauseButton aboveSubview:self.gifImageView];
        self.pauseButton.alpha = 0.7f;
        
        [UIView animateWithDuration:1.0 animations:^(void)
        {
            self.pauseButton.alpha = 0.0f;
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(removePauseButtonFromView) userInfo: nil repeats: NO];
        }];
        
        [self.gifImageView stopAnimating];
        self.tapToggle = @"1";
    }
    NSLog(@"tap recognized and tap toggle is %@", self.tapToggle);
}
-(void)removePlayButtonFromView
{
    [self.playButton removeFromSuperview];
}
-(void)removePauseButtonFromView
{
    [self.pauseButton removeFromSuperview];
}

- (IBAction)freeGameButton:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Ads!?" message:@"\nGif Bucket unlimited removed all ads and allows you to store an unlimited number of gifs!" delegate:self cancelButtonTitle:@"YES!" otherButtonTitles:@"Maybe Later...", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
    [alert show];
    
    self.comingFromUnlimited = @"YES";
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.comingFromUnlimited isEqualToString:@"YES"])
    {
        if(buttonIndex == 1)
        {
            // do nothing
        }
        if(buttonIndex == 0)
        {
            [[GifBucketIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
             {
                 if (success) {
                     self.productsArray = [products mutableCopy];
                     NSLog(@"Third cell pressed");
                     SKProduct *product = self.productsArray[1];
                     NSLog(@"Buying: %@", product.productIdentifier);
                     [[GifBucketIAPHelper sharedInstance] buyProduct:product];
                     
                 }
                 else
                 {
                     NSLog(@"NO SUCCESS");
                 }
                 
                 
             }];
        }
    }
    else
    {
        if(buttonIndex == 1)
        {
            // do nothing
        }
        if(buttonIndex == 0)
        {
            // NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector(showInterstitialAd) userInfo: nil repeats: NO];
        }
    }

}

- (void)checkAdCampaignStatus
{
    // get number of sent gifs through campaign
    // and turn off campaign if completed
    NSString *numberOfImports = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfApsDownloaded"];
    long i = numberOfImports.integerValue;
    NSLog(@"i is equal to %ld", i);
    if (i < 3) {
        i = i + 1;
        NSLog(@"i is now more at %ld", i);
        NSString *newNumberOfAppsDownloaded = [NSString stringWithFormat:@"%ld", i];
        NSLog(@"new sent gifs number: %@", newNumberOfAppsDownloaded);
        
        NSString *numberOfImports = newNumberOfAppsDownloaded;
        [[NSUserDefaults standardUserDefaults] setObject:numberOfImports forKey:@"numberOfApsDownloaded"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else if (i == 3)
    {
        BOOL adsRemoved = YES;
        [[NSUserDefaults standardUserDefaults] setBool:adsRemoved forKey:@"adsRemoved"];
        
        NSLog(@"ads will now be removed");
        [SVProgressHUD showSuccessWithStatus:@"Thank you for your support!\nAds have been removed."];
        
        // hide ads
        // [adView removeFromSuperview];
        removeAdsButtonOutlet.hidden = YES;
        freeGameButtonOutlet.hidden = YES;
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

// GIF BUCKET UNLIMITED
- (IBAction)removeAdsButtonAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Go Unlimited!?" message:@"\nGif Bucket unlimited removed all ads and allows you to store an unlimited number of gifs!" delegate:self cancelButtonTitle:@"YES!" otherButtonTitles:@"Maybe Later...", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
    [alert show];
    
    self.comingFromUnlimited = @"YES";
    
    /*

    */
}

- (void)productPurchased:(NSNotification *)notification
{
    
    NSString * productIdentifier = notification.object;
    [self.productsArray enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            if ([productIdentifier isEqualToString:@"com.jonbrown.GifBucket.gifbucketunlimited"])
            {
                // set user defaults unlimited value to YES
                BOOL unlimited = YES;
                [[NSUserDefaults standardUserDefaults] setBool:unlimited forKey:@"isUnlimited"];
                
                // hide ads
                // [adView removeFromSuperview];
                removeAdsButtonOutlet.hidden = YES;
                freeGameButtonOutlet.hidden = YES;
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
}

@end