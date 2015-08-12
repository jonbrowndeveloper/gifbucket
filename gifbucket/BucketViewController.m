//
//  BucketViewController.m
//  GIFBucket
//
//  Created by JB on 7/21/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "BucketViewController.h"
#import "BucketGifViewController.h"
#import "BucketCollectionViewCell.h"
#import "BucketTableViewCell.h"
#import "AppDelegate.h"
#import "GBCategory.h"
#import "GBGIFImage.h"
#import <QuartzCore/CALayer.h>
#import "NewBucketViewController.h"
#import "GifBucketIAPHelper.h"

@interface BucketViewController ()

@end

@implementation BucketViewController

@synthesize bucketTableView, alertTextField, fetchedResultsController = _fetchedResultsController, bucketManagedObjectContext, segueOnlyButton, numberOfBuckets;

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// setup managed object context

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

// get list of categories from database

-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;

    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GBCategory" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    segueOnlyButton.hidden = YES;
    
    // set navbar text and color
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:6.0/255.0 green:79.0/255.0 blue:134.0/255.0 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName :[UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:20.0f]
                                                                      }];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    // set insets for tab bar
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen making up for difference of bottom tab bar
        [self.bucketTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, (CGRectGetHeight(self.tabBarController.tabBar.frame) + 105.0), 0.0f)];
        
        
    } else {
        // This is other iPhone
        [self.bucketTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f)];
    }
    
    // Load Fetched Results Controller
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        NSLog(@"Fetch Error: %@, %@", error, [error userInfo]);
        exit(-1); // Kill the app
    }
    
    // stop table view from having multiple cells selected when moving back to view
    
    self.bucketTableView.allowsMultipleSelectionDuringEditing = NO;
    
          
}

- (void)viewWillAppear:(BOOL)animated
{

    // if there are no categories, press the add button to create one (always shown at the beginning of the app
    
    if ([_fetchedResultsController.fetchedObjects count] == 0)
    {
        [self performSelector:@selector(addButton:) withObject:self];
        
    }
    
    // if purchases were restored from the add buckets window, we will reload the tableview
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"purchaseRestored"])
    {
        [bucketTableView reloadData];
        
        BOOL restored = NO;
        [[NSUserDefaults standardUserDefaults] setBool:restored forKey:@"purchaseRestored"];
        
    }
    
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bucketViewRefreshed"])
    {
        [bucketTableView reloadData];
        NSLog(@"bucket view is reloading data");
        
        BOOL restored = NO;
        [[NSUserDefaults standardUserDefaults] setBool:restored forKey:@"bucketViewRefreshed"];
        
    }
    
    // [bucketTableView reloadData];

    // leaks memory a lot
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // send category name to bucket collection view
    if([segue.identifier isEqualToString:@"categorySegue"]){
        BucketTableViewCell *cell = (BucketTableViewCell *)sender;
        NSIndexPath *indexPath = [self.bucketTableView indexPathForCell:cell];
        
        BucketGifViewController *divc = (BucketGifViewController *)[segue destinationViewController];
        GBCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
        divc.currentCategory = [category categoryName];
        
        // NSLog(@"Current Category from parent view: %@", [category categoryName]);
    }
    // send category array to new bucket controller for comparing
    if([segue.identifier isEqualToString:@"buySegue"])
    {

        NewBucketViewController *divc = (NewBucketViewController *)[segue destinationViewController];
        divc.fetchedCategoryArray = [_fetchedResultsController fetchedObjects];
        
        divc.productsArray = nil;
        [[GifBucketIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
         {
             if (success) {
                 divc.productsArray = products;
             }
             else
             {
                 NSLog(@"NO SUCCESS");
             }
         }];
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    numberOfBuckets = [sectionInfo numberOfObjects];
    return [sectionInfo numberOfObjects];
}

-(void)configureCell:(BucketTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GBCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Bug: when new bucket is created after old bucket is delted, the gif still remains
    // current workaround, set placeholder to empty old cell gif if deleted
    
    // [cell.tableViewImageView.subviews
    cell.imageView.image = [UIImage imageNamed:@"placeholder_white.png"];
    
    // create fetch request for gif image entity
    
    NSManagedObjectContext *context2 = [self managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:context2]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentCategory == %@", [category categoryName]]];
    
    NSError* error = nil;
    NSArray * results = [context2 executeFetchRequest:fetchRequest error:&error];
    
    // get current gif path
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsDirectoryFull = [documentsDirectory stringByAppendingString:@"/"];
    
    CALayer *cellImageLayer = cell.tableViewImageView.layer;
    // [cellImageLayer setCornerRadius:33.0];
    [cellImageLayer setMasksToBounds:YES];
    
    if (results.count > 0)
    {
        cell.imageView.image = nil;
        
        GBGIFImage *firstGIF = [results objectAtIndex:0];
        NSString *firstImageName = [firstGIF imageName];
        
        // NSLog(@"first gif image name of %@ is %@", [category categoryName], firstImageName);
        
        NSString *fullGIFPath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.gif", firstImageName]];
        
        FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:fullGIFPath]];
        FLAnimatedImageView * theImageView = [[FLAnimatedImageView alloc] init];
        theImageView.animatedImage = image;
        theImageView.frame = CGRectMake(7.0, 7.0, 66.0, 66.0);
        [cell.tableViewImageView addSubview:theImageView];
        
        // NSLog(@"full gif path %@", fullGIFPath);
    }
    
    
    // configure cell
    
    NSInteger cellCount = results.count;
    long cellCountLong = cellCount;
    
    cell.cellTextLabel.text = [category categoryName];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"bucketAreLarger"])
    {
        cell.cellCountLabel.text = [NSString stringWithFormat:@"%li/10 GIFs", cellCountLong];
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"bucketAreLarger"])
    {
        cell.cellCountLabel.text = [NSString stringWithFormat:@"%li/15 GIFs", cellCountLong];
    }
    else
    {
        if (results.count == 1)
        {
            cell.cellCountLabel.text = [NSString stringWithFormat:@"1 GIF"];
        }
        else
        {
            cell.cellCountLabel.text = [NSString stringWithFormat:@"%li GIFs", cellCountLong];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"bucketCell";
    BucketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.bucketTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.bucketTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

// I dont need this method? One ever one section

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.bucketTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.bucketTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.bucketTableView endUpdates];
}

#pragma mark - Table View editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.bucketTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObjectContext *context2 = [self managedObjectContext];
    
    // create fetch request for gif image entity
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:context2]];
    
    GBCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *categoryString = [category categoryName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentCategory == %@", categoryString]];
    
    NSError* error = nil;
    NSArray * results = [context2 executeFetchRequest:fetchRequest error:&error];
    
    // create gif path request and delete files
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsDirectoryFull = [documentsDirectory stringByAppendingString:@"/"];
    
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
    [fetchRequest2 setEntity:[NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:context2]];
    [fetchRequest2 setPredicate:[NSPredicate predicateWithFormat:@"parentCategory == %@", categoryString]];
    
    // setup file manager for later file removal
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (GBGIFImage *gifObject in results)
    {
        // get both PNG and GIF file names
        
        NSString *gifName = [gifObject imageName];
        NSString *fullGIFPath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.gif", gifName]];
        NSString *fullPNGPath = [documentsDirectoryFull stringByAppendingString:[NSString stringWithFormat:@"%@.png", gifName]];
        
        // delete files
        
        [fileManager removeItemAtPath:fullGIFPath error:nil];
        [fileManager removeItemAtPath:fullPNGPath error:nil];
        
        // remove object from core data store
        
        [context2 deleteObject:gifObject];
    }
    
    // save
    
    [context2 deleteObject:managedObject];
    [context2 save:nil];
    [self.bucketTableView reloadData];
}

- (IBAction)addButton:(id)sender
{
    // get maximum number of buckets
    NSString *maimumNumberOfBuckets = [[NSUserDefaults standardUserDefaults] stringForKey:@"maximumNumberOfBuckets"];
    int maximumNumberOfBucketsInt = [maimumNumberOfBuckets intValue];
    
    NSString *titleString = @"Create a new bucket";
    NSString *placeholderString = @"";
    
    if (numberOfBuckets < maximumNumberOfBucketsInt && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        NSString *messageString = @"\n";
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTime"])
        {
            messageString = [NSString stringWithFormat:@"You are using %ld out of %@ availible buckets", (long)numberOfBuckets, [[NSUserDefaults standardUserDefaults] objectForKey:@"maximumNumberOfBuckets"]];
        }
        else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTime"])
        {
            titleString = @"Thank you for choosing \nGif Bucket";
            messageString = @"Store all your gifs in buckets.\nYou get one bucket free!";
            placeholderString = @"Name your first bucket";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeDefault;
        alertTextField.placeholder = placeholderString;
        NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
        [alert show];
    }
    else if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create a new bucket" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeDefault;
        NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:@"buySegue" sender:self];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSString *newCategoryResult = alertTextField.text;
        NSArray *fetchedObjects = [_fetchedResultsController fetchedObjects];
        NSLog(@"fetched objects %@", fetchedObjects);
        
        NSString *check = @"NO";
        
        // get maximum number of buckets
        NSString *maimumNumberOfBuckets = [[NSUserDefaults standardUserDefaults] stringForKey:@"maximumNumberOfBuckets"];
        int maximumNumberOfBucketsInt = [maimumNumberOfBuckets intValue];
        NSLog(@"Maximum Number of Buckets %d", maximumNumberOfBucketsInt);
        
        // check if name entered is already in use
        
        NSString *messageString = @"\n";
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
        {
            messageString = [NSString stringWithFormat:@"You are using %ld out of %@ availible buckets", (long)numberOfBuckets, [[NSUserDefaults standardUserDefaults] objectForKey:@"maximumNumberOfBuckets"]];
        }

        for (GBCategory *cateogry in fetchedObjects)
        {
            if ([[cateogry categoryName] isEqual:newCategoryResult])
            {
                check = @"YES";
            }
            
        }
        if ([check isEqual:@"YES"])
        {
            // if name in use, display new alert view with instructions
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name already in use" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeDefault;
            NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
            [alert show];
        }
        else if (newCategoryResult.length > 20 || newCategoryResult.length == 0)
        {
            // if mis-formatted string, display new alert view with instructions
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a name that is between 1 to 20 characters" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeDefault;
            NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
            [alert show];
        }
        else
        {
            // setup managed object context and create new category object
            NSManagedObjectContext *context = [self managedObjectContext];
            NSManagedObject *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"GBCategory" inManagedObjectContext:context];
            [newCategory setValue:newCategoryResult forKey:@"categoryName"];
            
            // save object to core data store
            
            NSError *error;
            [context save:&error];
            
            // [self.navigationController popToRootViewControllerAnimated:YES];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTime"])
            {
            
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFirstTime"];
                
                [self.tabBarController setSelectedIndex:0];
                
            }

        }
    }

}

@end
