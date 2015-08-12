//
//  AppDelegate.m
//  GIFBucket
//
//  Created by JB on 6/12/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "AppDelegate.h"
#import "GifBucketIAPHelper.h"
#import "AgreementViewController.h"
#import "Reachability.h"
#import "ALSdk.h"
#import "BucketGIFImageViewController.h"
#import "ACTReporter.h"
#import "AppsfireSDK.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize activityViewActivated;
@synthesize currentGifURLString;
@synthesize receivedGIFURL, searchString;
@synthesize badLinks, prohibitedSearchWords;
@synthesize isBeingCopied;

/*
// Find out who the current view controller is
- (UIViewController*)topViewController {
    // NSLog(@"we are in the 'top view controller method'");
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}
// get the 'rootviewcontroller'
- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    // NSLog(@"we are in the root view controller method");
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else
    {
        return rootViewController;
    }
}

// check to see if the selector 'canRotate' exists within the root view controller
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    // NSLog(@"we are in the current view controller method");
    // Get topmost/visible view controller
    
    UIViewController *currentViewController = [self topViewController];
    
    if ([currentViewController isKindOfClass:[BucketGIFImageViewController class]])
    {
        // NSLog(@"user interface unlocked");
        // Unlock landscape view orientations for this view controller
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    // Only allow portrait (standard behaviour)
    return UIInterfaceOrientationMaskPortrait;
    
}*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // start google install tracking support
    
    [ACTConversionReporter reportWithConversionID:@"957960831" label:@"RVgzCMiXtlkQ_6TlyAM" value:@"0.03" isRepeatable:NO];
    
    // start AppLovin support
    
    [ALSdk initializeSdk];
    
    // Start AppsFire
    
    [AppsfireSDK connectWithSDKToken:@"F70AA9980F8A7E4BC66C79F0996EB9FB" secretKey:@"14bc4309bc2034531c70db5783abe480" features:AFSDKFeatureMonetization parameters:nil];
    
#ifdef DEBUG
    [AppsfireSDK setDebugModeEnabled:YES];
#endif
    
    // Intial File Managment. Check if Documents Direcotry is there and add in Data and Recents Plists
    
    activityViewActivated = nil;
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // NSString *dataPath = [documentsDirectory stringByAppendingString:@"/Data.plist"];
    // NSString *recentsPath = [documentsDirectory stringByAppendingString:@"/Recents.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:documentsDirectory])
    {
        
        [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // setup shared instance for app purchasing
    [GifBucketIAPHelper sharedInstance];
    
    // create user prefs
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"preferencesSet"]) {
        // set initial maximum number of buckets
        NSString *numberOfBuckets = @"1";
        [[NSUserDefaults standardUserDefaults] setObject:numberOfBuckets forKey:@"maximumNumberOfBuckets"];
        
        // set bool for GIF Bucket Ultimate
        BOOL isUnlimited = YES; // currently of 
        [[NSUserDefaults standardUserDefaults] setBool:isUnlimited forKey:@"isUnlimited"];
        
        // set bool for restored purchases alert
        BOOL purchaseRestored = NO;
        [[NSUserDefaults standardUserDefaults] setBool:purchaseRestored forKey:@"purchaseRestored"];
        
        // set user prefs bool
        BOOL prefs = YES;
        [[NSUserDefaults standardUserDefaults] setBool:prefs forKey:@"preferencesSet"];
        
        // set first time bool
        BOOL isFirstTime = YES;
        [[NSUserDefaults standardUserDefaults] setBool:isFirstTime forKey:@"isFirstTime"];
        
        // set default sub reddits
        NSArray *subReddits = [[NSArray alloc] initWithObjects:
                                   @"Gifs",
                                   @"ReactionGifs",
                                   @"BabyBigCatGifs",
                                   @"BaseballGifs",
                                   @"ChemicalReactionGifs",
                                   @"BabyDuckGifs",
                                   @"WastedGifs",
                                   @"CatGifs",
                                   nil];
        [[NSUserDefaults standardUserDefaults] setObject:subReddits forKey:@"subReddits"];
        
        // syncronize
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"User Preferences Set");
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"update1PreferencesSet"])
    {
        // set bool for campaign on / off
        BOOL campaignOn = NO;
        [[NSUserDefaults standardUserDefaults] setBool:campaignOn forKey:@"campaignOn"];
        
        // set string for number of imports by user
        NSString *numberOfImports = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:numberOfImports forKey:@"numberOfImports"];
        
        NSString *numberOfSentGifs = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:numberOfSentGifs forKey:@"numberOfSentGifs"];
        
        // set bool for first bucket expanded storage space
        BOOL bucketAreLarger = NO;
        [[NSUserDefaults standardUserDefaults] setBool:bucketAreLarger forKey:@"bucketAreLarger"];
        
        // set bool for first bucket expanded storage space
        BOOL thankYouMessageComplete = NO;
        [[NSUserDefaults standardUserDefaults] setBool:thankYouMessageComplete forKey:@"thankYouMessageComplete"];
        
        // set bool for first bucket expanded storage space
        BOOL bucketViewRefreshed = NO;
        [[NSUserDefaults standardUserDefaults] setBool:bucketViewRefreshed forKey:@"bucketViewRefreshed"];
        
        // set bool for app review notice
        BOOL reviewNotice = YES;
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"reviewNotice"];
        
        // set bool for Gif Bucket Unlimited Reminder
        BOOL unlimitedNotice = YES;
        [[NSUserDefaults standardUserDefaults] setBool:unlimitedNotice forKey:@"unlimitedNotice"];
        
        // set user prefs bool
        BOOL prefs = YES;
        [[NSUserDefaults standardUserDefaults] setBool:prefs forKey:@"update1PreferencesSet"];
        
        NSLog(@"User Update 1 Preferences Set");
    }
    else
    {
        NSLog(@"we are updating from a previous version (1.1) or the program has already launched at least once");
        
        BOOL reviewNotice = YES;
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"fromOlderVersion1.1"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"update2PreferencesSet"])
    {
        // set bool for app review notice
        BOOL reviewNotice = NO;
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"adsRemoved"];
        
        // set string for number of imports by user
        NSString *numberOfApsDownloaded = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:numberOfApsDownloaded forKey:@"numberOfApsDownloaded"];
        
        // method so that the first time you launch the application the landscape option does not work.
        
        // set user prefs bool
        BOOL prefs = YES;
        [[NSUserDefaults standardUserDefaults] setBool:prefs forKey:@"update2PreferencesSet"];
    
        NSLog(@"User Update 2 Preferences Set");
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"update3PreferencesSet"])
    {
        // set bool for app review notice
        BOOL reviewNotice = NO;
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"hitRemindMeLater"];
        
        // bool if user has clicked to review app
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"completedReview"];
        
        // bool if user has clicked to review app
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"importingFromOtherApp"];
        
        // bool for showing tap help
        [[NSUserDefaults standardUserDefaults] setBool:reviewNotice forKey:@"helperShown"];
        
        // get number of times gif view has been loaded
        NSString *numberOfTimeGifViewLoaded = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:numberOfTimeGifViewLoaded forKey:@"numberOfTimeGifViewLoaded"];
        
        // set user prefs bool
        BOOL prefs = YES;
        [[NSUserDefaults standardUserDefaults] setBool:prefs forKey:@"update3PreferencesSet"];
        
        NSLog(@"User Update 3 Preferences Set");
    }
    

    
    #if TARGET_IPHONE_SIMULATOR
    // where is the iphone simulator path
    // NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    #endif
    
    badLinks = [NSArray arrayWithObjects:@"placeholder", nil];
    
    Reachability *linkS3Reachability = [Reachability reachabilityWithHostName:@"https://s3.amazonaws.com/badlinks/index.html"];
    NetworkStatus linkS3NetworkStatus = [linkS3Reachability currentReachabilityStatus];
    
    if (linkS3NetworkStatus == NotReachable)
    {
        // get list of bad / innapropriate links
        
        NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://s3.amazonaws.com/badlinks/index.html"]];
        NSData *queryData = [NSData dataWithContentsOfURL:queryURL];
        // NSLog(@"query Data: %@", queryData);
        
        // setup array from json
        
        NSError *errorJSON = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:queryData options:NSJSONReadingAllowFragments error:&errorJSON];
        // NSLog(@"bad links json %@", JSON);
        
        badLinks = [JSON valueForKeyPath:@"badlinks"];
        // NSLog(@"bad links array: %@", badLinks);
        
        NSLog(@"able to reach https://s3.amazonaws.com/badlinks/index.html");
    }
    else
    {
        NSLog(@"unable to reach https://s3.amazonaws.com/badlinks/index.html");
    }
    
    // get prohibited search list from main bundle
    
    NSString *filePathProhib = [[NSBundle mainBundle] pathForResource:@"prohibited" ofType:@"json"];
    NSData *prohibitData = [NSData dataWithContentsOfFile:filePathProhib];
    
    // setup array from json
    
    NSError *errorJSON2 = nil;
    NSDictionary *JSON2 = [NSJSONSerialization JSONObjectWithData:prohibitData options:NSJSONReadingAllowFragments error:&errorJSON2];
    // NSLog(@"bad links json %@", JSON2);
    
    prohibitedSearchWords = [JSON2 valueForKeyPath:@"prohibitedPhrases"];
    // NSLog(@"there are %lu bad search phrases.\n", (unsigned long)prohibitedSearchWords.count);
    // NSLog(@"bad words array: %@", prohibitedSearchWords);
    
    // set agreement window as first view if it is the first time opening the app
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTime"])
    {
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AgreementViewController"];
        
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
    }
    
    // to check if we have launched once since 1.2
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunched"])
    {
        // increase the number of launches
        
        NSInteger i = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfLaunches"];
        i = i + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"numberOfLaunches"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        int i = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"numberOfLaunches"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunched"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    return YES;
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // NSLog(@"open url: %@", url);
    receivedGIFURL = [[NSURL alloc] init];
    receivedGIFURL = url;
    return YES;
}
							
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GIFBucket.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
