//
//  NewBucketViewController.m
//  GIFBucket
//
//  Created by JB on 9/14/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "NewBucketViewController.h"
#import "GifBucketIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "GBCategory.h"
#import "NewBucketTableViewCell.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface NewBucketViewController ()


@end

@implementation NewBucketViewController

@synthesize fetchedCategoryArray, productsArray, productDescriptions, productTitles, prices, pictureNames, productsTableView, thankYouImageView, numberOfBucketsAvailibleLabel, restoreButton, timer;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // remove toolbar if coming from the gif imageview controller
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    // [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(checkIfUnlimited) userInfo: nil repeats: YES];
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen
        thankYouImageView.hidden = YES;
        
        NSLog(@"this is a smaller screen");
        
        CGRect oldFrame2 = numberOfBucketsAvailibleLabel.frame;
        CGRect newFrame2 = CGRectMake(oldFrame2.origin.x, oldFrame2.origin.y - 100, oldFrame2.size.width, oldFrame2.size.height);
        numberOfBucketsAvailibleLabel.frame = newFrame2;
        
        CGRect oldFrame3 = restoreButton.frame;
        CGRect newFrame3 = CGRectMake(oldFrame3.origin.x, oldFrame3.origin.y - 120, oldFrame3.size.width, oldFrame3.size.height);
        restoreButton.frame = newFrame3;
    } else
    {
        // This is other iPhone
        thankYouImageView.hidden = NO;
        CGRect oldFrame = thankYouImageView.frame;
        CGRect newFrame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y - 70, oldFrame.size.width, oldFrame.size.height);
        thankYouImageView.frame = newFrame;
        
        NSLog(@"this is a larger screen");
        
        CGRect oldFrame2 = numberOfBucketsAvailibleLabel.frame;
        CGRect newFrame2 = CGRectMake(oldFrame2.origin.x, oldFrame2.origin.y - 70, oldFrame2.size.width, oldFrame2.size.height);
        numberOfBucketsAvailibleLabel.frame = newFrame2;
        
        CGRect oldFrame3 = restoreButton.frame;
        CGRect newFrame3 = CGRectMake(oldFrame3.origin.x, oldFrame3.origin.y - 123, oldFrame3.size.width, oldFrame3.size.height);
        restoreButton.frame = newFrame3;
        
    }
    
    thankYouImageView.image = [UIImage imageNamed:@"gifbucket-title-original-blue60"];
    
    [self performSelector:@selector(updateBucketNumberLabel)];
    
    prices = [[NSArray alloc] initWithObjects:@"$0.99", @"$2.99",@"$4.99", nil];
    productTitles = [[NSArray alloc] initWithObjects:@"Single Bucket", @"Bucket Bundle", @"Gif Bucket Unlimited", nil];
    productDescriptions = [[NSArray alloc] initWithObjects:@"Store up to 10 gifs",@"Store up to 50 gifs in 5 buckets", @"Unlimited buckets and gifs! No Ads!", nil];
    pictureNames = [[NSArray alloc] initWithObjects:@"gifbucketicon-1.png",@"gifbucketicon-5.png", @"gifbucketicon-infinite.png", nil];
}

- (void)checkIfUnlimited
{
    NSLog(@"checking");
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        NSLog(@"This user has purchase unlimited");
        self.productsTableView.hidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)updateBucketNumberLabel
{
    NSString *maximumNumberOfBuckets = [[NSUserDefaults standardUserDefaults] objectForKey:@"maximumNumberOfBuckets"];
    NSLog(@"current maximum: %@", maximumNumberOfBuckets);
    long numberOfBuckets = maximumNumberOfBuckets.integerValue;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        if (numberOfBuckets == 1)
        {
            numberOfBucketsAvailibleLabel.text = @"You currently have 1 bucket";
        }
        else
        {
            numberOfBucketsAvailibleLabel.text = [NSString stringWithFormat:@"You currently have %@ buckets", [[NSUserDefaults standardUserDefaults] objectForKey:@"maximumNumberOfBuckets"]];
        }
        
    }
}
/*
-(void)showImageView
{
    thankYouImageView.hidden = NO;
    
    // add gif to imageview
    
    NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:@"black-and-whiteThankYou" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:bundleFilePath];
    
    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:gifData];
    FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
    theImageView.animatedImage = image;
    
    theImageView.frame = CGRectMake(0.0, 0.0, 266.0, 266.0);
    
    [thankYouImageView addSubview:theImageView];
}
*/
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [timer invalidate];
    timer = nil;
}

- (void)productPurchased:(NSNotification *)notification
{
    
    NSString * productIdentifier = notification.object;
    [productsArray enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            if ([productIdentifier isEqualToString:@"com.jonbrown.GifBucket.singlebucket1"])
            {
                // increase number of buckets by 1
                NSString *maximumNumberOfBuckets = [[NSUserDefaults standardUserDefaults] objectForKey:@"maximumNumberOfBuckets"];
                NSLog(@"current maximum: %@", maximumNumberOfBuckets);
                long i = maximumNumberOfBuckets.integerValue + 1;
                NSString *newMaximumNumberOfBuckets = [NSString stringWithFormat:@"%ld", i];
                NSLog(@"new maximum: %@", newMaximumNumberOfBuckets);
                
                [[NSUserDefaults standardUserDefaults] setObject:newMaximumNumberOfBuckets forKey:@"maximumNumberOfBuckets"];
                
                [self performSelector:@selector(updateBucketNumberLabel)];
            }
            else if ([productIdentifier isEqualToString:@"com.jonbrown.GifBucket.bucketbundle5"])
            {
                // increase number of buckets by 5
                NSString *maximumNumberOfBuckets = [[NSUserDefaults standardUserDefaults] objectForKey:@"maximumNumberOfBuckets"];
                NSLog(@"current maximum: %@", maximumNumberOfBuckets);
                long i = maximumNumberOfBuckets.integerValue + 5;
                NSString *newMaximumNumberOfBuckets = [NSString stringWithFormat:@"%ld", i];
                NSLog(@"new maximum: %@", newMaximumNumberOfBuckets);
                
                [[NSUserDefaults standardUserDefaults] setObject:newMaximumNumberOfBuckets forKey:@"maximumNumberOfBuckets"];
                
                [self performSelector:@selector(updateBucketNumberLabel)];
            }
            else if ([productIdentifier isEqualToString:@"com.jonbrown.GifBucket.gifbucketunlimited"])
            {
                // set user defaults unlimited value to YES
                BOOL unlimited = YES;
                [[NSUserDefaults standardUserDefaults] setBool:unlimited forKey:@"isUnlimited"];
                // self.productsTableView.hidden = YES;
                
                // [self performSelector:@selector(showImageView)];
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [productsTableView reloadData];
            *stop = YES;
        }
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewBucketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"purchaseCell" forIndexPath:indexPath];
    
    cell.descriptionLabel.text = productDescriptions[indexPath.row];
    cell.titleLabel.text = productTitles[indexPath.row];
    cell.priceLabel.text = prices[indexPath.row];
    cell.bucketIconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", pictureNames[indexPath.row]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NSLog(@"First cell pressed");
        SKProduct *product = productsArray[2];
        NSLog(@"Buying: %@", product.productIdentifier);
        [[GifBucketIAPHelper sharedInstance] buyProduct:product];
    }
    else if (indexPath.row == 1)
    {
        NSLog(@"Second cell pressed");
        SKProduct *product = productsArray[0];
        NSLog(@"Buying: %@", product.productIdentifier);
        [[GifBucketIAPHelper sharedInstance] buyProduct:product];
    }
    else if (indexPath.row == 2)
    {
        NSLog(@"Third cell pressed");
        SKProduct *product = productsArray[1];
        NSLog(@"Buying: %@", product.productIdentifier);
        [[GifBucketIAPHelper sharedInstance] buyProduct:product];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)restoreButtonAction:(id)sender
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
@end
