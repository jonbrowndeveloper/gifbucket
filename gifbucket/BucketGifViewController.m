//
//  BucketGifViewController.m
//  GIFBucket
//
//  Created by Brown, Jon on 7/21/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "BucketGifViewController.h"
#import "BucketCollectionViewCell.h"
#import "AppDelegate.h"
#import "GBGIFImage.h"
#import "BucketGIFImageViewController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"


@interface BucketGifViewController ()
{
    BOOL editEnabled;
}

@end

@implementation BucketGifViewController

@synthesize currentCategory, images, categories, bucketCollectionView, currentSliderValue, fetchedResultsController = _fetchedResultsController, collectionManagedObjectContext, currentlyTapped, emptyBucketLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.blockOperation = [NSBlockOperation new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.bucketCollectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] ];
            }];
            break;
        }

        case NSFetchedResultsChangeDelete: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            }];
            break;
        }

        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            }];
            break;
        }

        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveSection:indexPath.section toSection:newIndexPath.section];
            }];
            break;
        }

        default:
            break;
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
        NSLog(@"it was nil");
        
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentCategory == %@", currentCategory];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"imageName" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self fetchedResultsController] performFetch:nil];
    
    NSLog(@"current category: %@", currentCategory);
    
    [bucketCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    emptyBucketLabel.hidden = YES;
    
    if ([_fetchedResultsController.fetchedObjects count] == 0)
    {
        emptyBucketLabel.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // hide tab bar to show toolbar
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [bucketCollectionView reloadData];
    

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // check to make sure segue is correct and send info to GIF image view controller
    if([segue.identifier isEqualToString:@"toImage"])
    {
        UICollectionViewCell *cell = (UICollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.bucketCollectionView indexPathForCell:cell];
        
        NSLog(@"index path: %@", indexPath);
        
        // send selected image name to next controller
        
        BucketGIFImageViewController *divc = (BucketGIFImageViewController *)[segue destinationViewController];
        GBGIFImage *gifImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
        divc.currentGIFImage = [gifImage imageName];
        
        NSLog(@"current image name: %@", [gifImage imageName]);
    }
}

#pragma mark - Collection View Cell Implementation

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"fetched: %@", _fetchedResultsController);
    return [sectionInfo numberOfObjects];
    // return the number of gifs from the fetched results controller
}

- (BucketCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BucketCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bucketCVC" forIndexPath:indexPath];
    
    // Load PNG Thumbnail from file
    
    GBGIFImage *gifImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *imageName = [gifImage imageName];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsDirectoryFull = [documentsDirectory stringByAppendingString:@"/"];
    
    NSString *collectionViewGIFPath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.png",imageName]];
    
    NSLog(@"image name: %@", collectionViewGIFPath);
    
    UIImage *currentImage = [UIImage imageWithContentsOfFile:collectionViewGIFPath];
    
    cell.gifImage.image = currentImage;
        
    return cell;

}
@end
