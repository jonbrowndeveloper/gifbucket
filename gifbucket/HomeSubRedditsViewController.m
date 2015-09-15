//
//  HomeSubRedditsViewController.m
//  GIFBucket
//
//  Created by JB on 8/26/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "HomeSubRedditsViewController.h"
#import "HomeRedditWebViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"

@interface HomeSubRedditsViewController ()

@end

@implementation HomeSubRedditsViewController

@synthesize subReddits, subRedditsTableView, redditManagedObjectContext = _redditManagedObjectContext, redditFetchArray, alertTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add swipe gesture
    
    // -- EDIT Added the allocation of a UIGestureRecognizer -- //
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousView:)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    subReddits = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subReddits"]];
    
    NSLog(@"subreddits %@", subReddits);
    
    self.subRedditsTableView.allowsMultipleSelectionDuringEditing = NO;
    
    // setup navbar
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:6.0/255.0 green:79.0/255.0 blue:134.0/255.0 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName :[UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:20.0f]
                                                                      }];

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)gotoPreviousView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    // get cateogories to make sure there is a bucket
    
    if (_redditManagedObjectContext == nil)
    {
        _redditManagedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
    }
    
    NSFetchRequest *categoryRequest = [NSFetchRequest fetchRequestWithEntityName:@"GBCategory"];
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"GBCategory" inManagedObjectContext:_redditManagedObjectContext];
    categoryRequest.resultType = NSDictionaryResultType;
    categoryRequest.propertiesToFetch = [NSArray arrayWithObjects:[[categoryEntity propertiesByName] objectForKey:@"categoryName"], nil];
    categoryRequest.returnsDistinctResults = YES;
    
    self.redditFetchArray = [_redditManagedObjectContext executeFetchRequest:categoryRequest error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- tableview methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [subReddits count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"subReddit"];
    
    cell.textLabel.text = [subReddits objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([redditFetchArray count] == 0)
    {
        [self.tabBarController setSelectedIndex:1];
    }
    else
    {
        [self performSegueWithIdentifier:@"toReddit" sender:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"We are in the segue");
    if([segue.identifier isEqualToString:@"toReddit"])
    {
        HomeRedditWebViewController *divc = (HomeRedditWebViewController *)[segue destinationViewController];
        NSIndexPath *selectedIndexPath = [self.subRedditsTableView indexPathForSelectedRow];
        NSLog(@"Selected Index Path: %@", selectedIndexPath);
        
        divc.currentSubReddit = [subReddits objectAtIndex:selectedIndexPath.row];
        
        NSLog(@"Current Category from parent view: %ld", (long)selectedIndexPath.row);
    }
}

- (IBAction)addSubredditButton:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a new gif subreddit" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    [alert setTag:1];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (alertView.tag == 1)
    {
        
        if(buttonIndex == 1)
        {
            Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
            
            NSString *newCategoryResult = alertTextField.text;

            
            NSString *dataCheck;
            if (networkStatus == NotReachable)
            {
                UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"Make sure you have a working internet connection" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                noConnectionAlert.alertViewStyle = UIAlertViewStyleDefault;
                
                [noConnectionAlert show];
            }
            else
            {
                if (newCategoryResult.length < 30 && newCategoryResult.length != 0)
                {
                    NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/r/%@.json", newCategoryResult]];
                    NSData *queryData = [NSData dataWithContentsOfURL:queryURL];
                    
                    // setup nsdata from json
                    
                    NSError *errorJSON = nil;
                    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:queryData options:NSJSONReadingAllowFragments error:&errorJSON];
                    
                    NSLog(@"JSON %@", JSON);
                    
                    dataCheck = [JSON valueForKeyPath:@"data.after"];
                    
                    NSLog(@"date check = %@", dataCheck);
                }
                if (newCategoryResult.length > 30 || newCategoryResult.length == 0)
                {
                    // if mis-formatted string, display new alert view with instructions
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a name that is between 1 to 30 characters" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertTextField = [alert textFieldAtIndex:0];
                    alertTextField.keyboardType = UIKeyboardTypeDefault;
                    [alert setTag:1];
                    NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
                    [alert show];
                }
                else if(dataCheck == nil || [dataCheck isEqual:[NSNull null]])
                {
                    // if mis-formatted string, display new alert view with instructions
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"That does not appear to be a subreddit" message:@"\nTry Again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertTextField = [alert textFieldAtIndex:0];
                    alertTextField.keyboardType = UIKeyboardTypeDefault;
                    [alert setTag:1];
                    NSLog(@"cancel button index: %ld", (long)[alert cancelButtonIndex]);
                    [alert show];
                }
                else
                {
                    [subReddits addObject:newCategoryResult];
                    NSArray *quickSubRedditsArray = [NSArray arrayWithArray:subReddits];
                    [[NSUserDefaults standardUserDefaults] setObject:quickSubRedditsArray forKey:@"subReddits"];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self.subRedditsTableView reloadData];
                }
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [subReddits removeObjectAtIndex:indexPath.row];
        
        NSArray *quickSubRedditsArray = [NSArray arrayWithArray:subReddits];
        [[NSUserDefaults standardUserDefaults] setObject:quickSubRedditsArray forKey:@"subReddits"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.subRedditsTableView reloadData];
    }   

}

@end
