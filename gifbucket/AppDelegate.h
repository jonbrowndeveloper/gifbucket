//
//  AppDelegate.h
//  GIFBucket
//
//  Created by JB on 6/12/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSString *activityViewActivated;
@property (nonatomic, strong) NSString *currentGifURLString;
@property (nonatomic, strong) NSURL *receivedGIFURL;
// arrays for subreddits controller
@property (nonatomic, strong) NSMutableArray *receivedGifUrls;
@property (nonatomic, strong) NSMutableArray *receivedPostTitles;
// string for search controller
@property (nonatomic, strong) NSString *searchString;
// array of bad / innapropriate links
@property (nonatomic, strong) NSArray *badLinks;
// list of prohibited search words
@property (nonatomic, strong) NSArray *prohibitedSearchWords;
// data for copying to clipboard
@property (nonatomic, strong) NSString *isBeingCopied;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
