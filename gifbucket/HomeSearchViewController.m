//
//  HomeSearchViewController.m
//  GIFBucket
//
//  Created by Brown, Jon on 8/27/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "HomeSearchViewController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "ImportToCategoryViewController.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "AppDelegate.h"


@interface HomeSearchViewController ()

@end

@implementation HomeSearchViewController

@synthesize pulledURLString, recievedSearchQueryString, segueActivated, receivedArrayFull, receivedArrayReduced, searchCollectionView, searchString, downloadedString;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSLog(@"received full array: %@", receivedArrayFull);
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen making up for difference of bottom tab bar
        [self.searchCollectionView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, (CGRectGetHeight(self.tabBarController.tabBar.frame) + 105.0), 0.0f)];
        
        
    } else {
        // This is other iPhone
        [self.searchCollectionView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f)];
    }
    
    // check to see if there were any results and if so, display message
    
    
    searchCollectionView.backgroundColor = [UIColor whiteColor];
    
    // set bar tint
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    for (int i = 3; i < 30; i++)
    {
        [NSTimer scheduledTimerWithTimeInterval:i target:self selector:@selector(reloadCollectionViewData) userInfo:nil repeats:NO];
        i = i +2;
    }
}

// if there is a solid network connection, get the json response from giphy from the search

- (void)viewWillAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
        
        if (networkStatus == ReachableViaWWAN)
        {
            [SVProgressHUD showWithStatus:@"Loading..."];
            
            // setup query to GIPHY
            
            downloadedString = @"NO";
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.giphy.com/v1/gifs/search?q=%@&api_key=eCkJ8BmBAruIo", [appDelegate searchString]]];
            NSData *queryData = [NSData dataWithContentsOfURL:queryURL];
            NSLog(@"query Data: %@", queryData);
            
            // setup nsdata from json
            
            NSError *errorJSON = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:queryData options:NSJSONReadingMutableContainers error:&errorJSON];
            NSLog(@"dictionary %@", JSON);
            
            // fill reduced and full array with gif urls
            
            receivedArrayReduced = [JSON valueForKeyPath:@"data.images.downsized_still.url"];
            
            receivedArrayFull = [JSON valueForKeyPath:@"data.images.original.url"];
        }
        else
        {
            
            
            // setup query to GIPHY
            
            downloadedString = @"NO";
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.giphy.com/v1/gifs/search?q=%@&api_key=eCkJ8BmBAruIo", [appDelegate searchString]]];
            NSData *queryData = [NSData dataWithContentsOfURL:queryURL];
            NSLog(@"query Data: %@", queryData);
            
            // setup nsdata from json
            
            NSError *errorJSON = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:queryData options:NSJSONReadingMutableContainers error:&errorJSON];
            NSLog(@"dictionary %@", JSON);
            
            // fill reduced and full array with gif urls
            
            receivedArrayReduced = [JSON valueForKeyPath:@"data.images.downsized.url"];
            
            receivedArrayFull = [JSON valueForKeyPath:@"data.images.original.url"];
        }
        
        downloadedString = @"YES";
        NSLog(@"downloaded string is: %@", downloadedString);
    });

        [self.searchCollectionView reloadData];
}

-(void)reloadCollectionViewData
{
    if ([downloadedString isEqualToString:@"YES"] && receivedArrayFull.count != 0)
    {
        
        [self.searchCollectionView reloadData];
        NSLog(@"reloading data...");
        downloadedString = @"DONE";
    }
    
    if (receivedArrayFull.count == 0 && [downloadedString isEqualToString:@"YES"])
    {
        UIAlertView *noDataAlert = [[UIAlertView alloc] initWithTitle:@"The search did not yield any results..." message:@"\n" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noDataAlert.alertViewStyle = UIAlertViewStyleDefault;
        
        [noDataAlert show];
        [SVProgressHUD dismiss];
        downloadedString = @"DONE";
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (UICollectionViewCell *cell in [self.searchCollectionView visibleCells])
    {
        // remove subviews from cells to free up memory
        [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return receivedArrayReduced.count;
    // return the number of gifs from the fetched results controller
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Loading... %ld of %lu", (long)indexPath.row, (unsigned long)receivedArrayFull.count]];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchCell" forIndexPath:indexPath];
    
    if (cell != nil) {
        [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    // dismiss activity view as soon as all of the gifs have been loaded
    /*
    if (indexPath.row == receivedArrayFull.count) {
        [SVProgressHUD dismiss];
    }
     */
    if (receivedArrayFull.count != 0 && [downloadedString isEqualToString:@"DONE"])
    {
        
        NSURL *gifURL = [NSURL URLWithString:receivedArrayReduced[indexPath.row]];
        
        
         // download the image asynchronously
         [self downloadImageWithURL:gifURL completionBlock:^(BOOL succeeded, FLAnimatedImageView *theImageView){
         if (succeeded)
         {
         // change the image of cell to GIF
            [cell addSubview:theImageView];
            [SVProgressHUD dismiss];
         }
         }];
        
        /*
        // download the image asynchronously
        [self downloadImageWithURL:gifURL completionBlock:^(BOOL succeeded, UIImage *image){
            if (succeeded)
            {
                // change the image of cell to GIF
                cell.backgroundColor = [UIColor colorWithPatternImage:image];
                
                
            }
        }];*/
    }
    
    return cell;
}
/*
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [UIImage imageWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}*/

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, FLAnimatedImageView *theImageView))completionBlock
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   
                                   FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
                                   FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
                                   theImageView.animatedImage = image;
                                   theImageView.frame = CGRectMake(0.0, 0.0, 158.0, 158.0);
                                   completionBlock(YES,theImageView);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // send category name to bucket collection view
    if([segue.identifier isEqualToString:@"fromSearchToImport"]){

        NSURL *url = [NSURL URLWithString:searchString];

        ImportToCategoryViewController *divc = (ImportToCategoryViewController *)[segue destinationViewController];
        divc.urlString = url;
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // set selected gif's url to clipboard and segue to import view
    
    searchString = receivedArrayFull[indexPath.row];
    
    // UIPasteboard *pasteboardCurrent = [UIPasteboard generalPasteboard];
    // pasteboardCurrent.URL = url;
    
    [self performSegueWithIdentifier:@"fromSearchToImport" sender:self];
}

@end
