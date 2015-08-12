//
//  APActivityProvider.m
//  GIFBucket
//
//  Created by JB on 10/5/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "APActivityProvider.h"
#import "HomeViewController.h"
#import "AppDelegate.h"

@implementation APActivityProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // various activity types
    
    if ([activityType isEqualToString:UIActivityTypeMessage])
    {
        [self performSelector:@selector(checkCampaignStatus)];
        return nil;
    }
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
    {
        [self performSelector:@selector(checkCampaignStatus)];
        return appDelegate.currentGifURLString;
    }
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] )
    {
        [self performSelector:@selector(checkCampaignStatus)];
        return appDelegate.currentGifURLString;
    }
    // if ( [activityType isEqualToString:UIActivityTypePostToFlickr])
    //     return [appDelegate currentGifURLString];
    if ( [activityType isEqualToString:UIActivityTypeMail] )
    {
        [self performSelector:@selector(checkCampaignStatus)];
        return appDelegate.currentGifURLString;
    }
    // copy is diferrent as it will leave out the textToShare statement
    if ( [activityType isEqualToString:UIActivityTypeCopyToPasteboard])
    {
        [self performSelector:@selector(checkCampaignStatus)];
        return appDelegate.currentGifURLString;
    }
    return nil;
}

- (void)checkCampaignStatus
{    
    // get number of sent gifs through campaign
    // and turn off campaign if completed
    NSString *numberOfImports = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfSentGifs"];
    long i = numberOfImports.integerValue;
    NSLog(@"i is equal to %ld", i);
    if (i < 5 && [[NSUserDefaults standardUserDefaults] boolForKey:@"campaignOn"]) {
        i = i + 1;
        
        NSString *newNumberOfSentGifs = [NSString stringWithFormat:@"%ld", i];
        NSLog(@"new sent gifs number: %@", newNumberOfSentGifs);
        
        [[NSUserDefaults standardUserDefaults] setObject:newNumberOfSentGifs forKey:@"numberOfSentGifs"];

    }
    else if (i == 5 && [[NSUserDefaults standardUserDefaults] boolForKey:@"campaignOn"])
    {
        BOOL campaignOff = NO;
        [[NSUserDefaults standardUserDefaults] setBool:campaignOff forKey:@"campaignOn"];
        
        BOOL increaseStorage = YES;
        [[NSUserDefaults standardUserDefaults] setBool:increaseStorage forKey:@"bucketAreLarger"];
        NSLog(@"Campaign is over and buckets are now larger");
        
        BOOL restored = YES;
        [[NSUserDefaults standardUserDefaults] setBool:restored forKey:@"bucketViewRefreshed"];
        // add to number of sent gifs
        
        BOOL messageSeen = NO;
        [[NSUserDefaults standardUserDefaults] setBool:messageSeen forKey:@"restartMessageSeen"];
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

@end
