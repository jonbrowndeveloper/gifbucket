//
//  HomeRedditWebViewController.m
//  GIFBucket
//
//  Created by JB on 8/26/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "HomeRedditWebViewController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "SVProgressHUD.h"
#import "RedditTableViewCell.h"
#import "Reachability.h"
#import "ImportToCategoryViewController.h"
#import "AppDelegate.h"


@interface HomeRedditWebViewController ()

@end

@implementation HomeRedditWebViewController

@synthesize currentSubReddit, pulledURLStringReddit, pulledStringReddit,receivedGifUrls, receivedPostTitles, subredditResultsTableView, receivedPostOverEighteen, gifvDownloadLinkList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    subredditResultsTableView.backgroundColor = [UIColor whiteColor];
    
    // setup network reliability
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    
    // set collection view insets
    
    NSMutableArray *receivedURLTemp;
    NSMutableArray *receievedCommentTemp;
    NSMutableArray *reveivedOverEighteenTemp;
    
    // NSMutableArray *gifvDownloadLinkListTemp;
    
    receivedGifUrls = [[NSMutableArray alloc] init];
    receivedPostTitles = [[NSMutableArray alloc] init];
    gifvDownloadLinkList = [[NSMutableArray alloc] init];
    
    // receivedPostOverEighteen = [[NSMutableArray alloc] init];
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen making up for difference of bottom tab bar
        [self.subredditResultsTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, (CGRectGetHeight(self.tabBarController.tabBar.frame) + 105.0), 0.0f)];
        
        
    } else {
        // This is other iPhone
        [self.subredditResultsTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f)];
    }
    
    // get JSON data and check network connection
    
    if (networkStatus == NotReachable)
    {
        UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"Make sure you have a working internet connection" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noConnectionAlert.alertViewStyle = UIAlertViewStyleDefault;
        
        [noConnectionAlert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        // setup query to Reddit
        
        NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/r/%@.json", currentSubReddit]];
        NSData *queryData = [NSData dataWithContentsOfURL:queryURL];
        
        // setup nsdata from json
        
        NSError *errorJSON = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:queryData options:NSJSONReadingMutableContainers error:&errorJSON];
        // NSLog(@"%@", JSON);
        
        // fill reduced and full array with gif urls
        
        receivedURLTemp = [JSON valueForKeyPath:@"data.children.data.url"];
        receievedCommentTemp = [JSON valueForKeyPath:@"data.children.data.title"];
        reveivedOverEighteenTemp = [JSON valueForKeyPath:@"data.children.data.over_18"];
        NSLog(@"over 18? %@", reveivedOverEighteenTemp);
        
    }
    receivedPostOverEighteen = reveivedOverEighteenTemp;
    NSLog(@"over 18 non temp: %@", receivedPostOverEighteen);
    // only add actual gif posts to table view
    
    // get bad links from master list
    NSArray *quickBadLinksArray = [appDelegate badLinks];
    NSLog(@"bad links %@", quickBadLinksArray);
    for (int i = 0; i < receivedURLTemp.count; i++)
    {
        NSString *currentGifURL = receivedURLTemp[i];
        // NSLog(@"current gif: %@", currentGifURL);
        
        // checking to see if there are any bad links within the pulled links from reddit
        
        NSUInteger barIndex = [quickBadLinksArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj caseInsensitiveCompare:receivedURLTemp[i]] == NSOrderedSame) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        // get rid of gifv links and simply use the gif version
        
        if ([currentGifURL rangeOfString:@".gifv"].location == NSNotFound || barIndex != NSNotFound)
        {
            // NSLog(@"url has not been changed");
            
            // test gifv
            
            // http://imgur.com/download/Ao4sBrV
        }
        else
        {
            NSString *tempString = [currentGifURL substringWithRange:NSMakeRange(9, [currentGifURL length] -10)];
            NSString *fullTempString = [NSString stringWithFormat:@"http://%@", tempString];
            currentGifURL = fullTempString;
            NSLog(@"current gif url is now: %@ and is number %d", currentGifURL, i);
            
            if ([currentGifURL rangeOfString:@"imgur"].location == NSNotFound )
            {
                NSString *placeholder = @"placeholder";
                [gifvDownloadLinkList addObject:placeholder];
            }
            else
            {
                NSString *imageID = [tempString substringWithRange:NSMakeRange(9, [tempString length] - 13)];
                NSLog(@"image ID = %@", imageID);
                NSString *imageDownloadLink = [NSString stringWithFormat:@"http://imgur.com/download%@", imageID];
                [gifvDownloadLinkList addObject:imageDownloadLink];
            }
            
        }
        
        // another check to make sure no over 18 gifs slip in there
        
        if ([currentGifURL rangeOfString:@".gif"].location == NSNotFound || [receivedPostOverEighteen[i] boolValue] || barIndex != NSNotFound)
        {
            // NSLog(@"no .gif in %@ or is NSFW", currentGifURL);
        }
        else
        {
            // NSLog(@"current gif: %@ \nhas a .gif in it", currentGifURL);
            [receivedGifUrls addObject:currentGifURL];
            [receivedPostTitles addObject:receievedCommentTemp[i]];
            NSString *placeholder = @"placeholder";
            [gifvDownloadLinkList addObject:placeholder];
        }
        
        if ([currentGifURL rangeOfString:@".jpg"].location == NSNotFound || [receivedPostOverEighteen[i] boolValue] || barIndex != NSNotFound)
        {
           // NSLog(@"no .jpg in %@ or NSFW", currentGifURL);
        }
        else
        {
            // NSLog(@"current gif: %@ \nhas a .jpg in it", currentGifURL);
            [receivedGifUrls addObject:currentGifURL];
            [receivedPostTitles addObject:receievedCommentTemp[i]];
            NSString *placeholder = @"placeholder";
            [gifvDownloadLinkList addObject:placeholder];
        }
        

        
    }
    
    // final check if there are no gifs pulled from the json, error will come up and move away from this window
    
    if ([receivedGifUrls count] == 0)
    {
        UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"No Results" message:@"is this a gif subreddit?" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noConnectionAlert.alertViewStyle = UIAlertViewStyleDefault;
        
        [noConnectionAlert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // NSLog(@"received URLs %@", receivedGifUrls);
    
    [appDelegate setReceivedGifUrls:receivedGifUrls];
    [appDelegate setReceivedPostTitles:receivedPostTitles];
    
    NSLog(@"gifv download list: \n%@", gifvDownloadLinkList);
    
    // NSLog(@"received Titles %@", receivedPostTitles);
    
    // reload table view to show thumbnails that have already been downloaded in the background
    for (int i = 1; i < 10; i++) {
        [NSTimer scheduledTimerWithTimeInterval:i target:self selector:@selector(reloadTableViewData) userInfo:nil repeats:NO];
    }
}

#pragma mark -- tableview methods

- (void)reloadTableViewData
{
    [subredditResultsTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate receivedGifUrls].count;
}

- (RedditTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    RedditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subviewCell" forIndexPath:indexPath];
     cell.titleLabel.text = [appDelegate receivedPostTitles][indexPath.row];
    
   NSString * currentURLString = [appDelegate receivedGifUrls][indexPath.row];
    
    if ([currentURLString rangeOfString:@"imgur"].location == NSNotFound)
    {
        cell.imageView.image = [UIImage imageNamed:@"placeholder_white.png"];
    }
    else if ([appDelegate receivedGifUrls].count != 0)
    {
        // NSLog(@"started loop at row %ldl", (long)indexPath.row);
        NSString *truncatedURL = [currentURLString substringToIndex:[currentURLString length] - 4];
        NSString *thumbnailString = [truncatedURL stringByAppendingString:@"b.gif"];
        // NSLog(@"current %@", thumbnailString);
        NSURL *currentURL = [NSURL URLWithString:thumbnailString];
        
        // download the thumbnail images asynchronously
        [self downloadImageWithURL:currentURL completionBlock:^(BOOL succeeded, UIImage *theThumbnail){
            if (succeeded)
            {
                // add thumbnail to current cell
                cell.imageView.image = theThumbnail;
                // [SVProgressHUD dismiss];
            }
        }];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

// asyncronous download

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *theThumbnail))completionBlock
{
    
    // [SVProgressHUD show];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [UIImage imageWithData:data];
                                   
                                   
                                   
                                   completionBlock(YES,image);
                                 
                               } else
                               {
                                   completionBlock(NO,nil);
                               }
                           }];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.subredditResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Segue Identifier = fromRedditToImport

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // send category name to bucket collection view
    if([segue.identifier isEqualToString:@"fromRedditToImport"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        RedditTableViewCell *cell = (RedditTableViewCell *)sender;
        NSIndexPath *indexPath = [self.subredditResultsTableView indexPathForCell:cell];
        
        NSString *currentString = [[appDelegate receivedGifUrls] objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:currentString];
        
        NSString *currentDownloadStrign = [gifvDownloadLinkList objectAtIndex:indexPath.row];
        NSURL *downloadURL = [NSURL URLWithString:currentDownloadStrign];
        
        // UIPasteboard *pasteboardCurrent = [UIPasteboard generalPasteboard];
        // pasteboardCurrent.URL = url;
        
        ImportToCategoryViewController *divc = (ImportToCategoryViewController *)[segue destinationViewController];
        divc.urlString = url;
        divc.urlDownloadString = downloadURL;
    }
}
@end
