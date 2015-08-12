//
//  ImportToCategoryViewController.m
//  GIFBucket
//
//  Created by Brown, Jon on 7/24/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "ImportToCategoryViewController.h"
#import "AppDelegate.h"
#import "GBCategory.h"
#import "GBGIFImage.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import <QuartzCore/QuartzCore.h>

@interface ImportToCategoryViewController ()

@end

@implementation ImportToCategoryViewController

@synthesize categoryPicker, importCategories, categoryKeys, uniqueFileName, importGIFPath, importedGIFImageView, wasImportPressed, importManagedObjectContext = _importManagedObjectContext, selectedCategory, importButton, gifDictionary, urlString, urlDownloadString, flagButton, bucketIsFull;

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


    
    // hide import button and configue look / location
    
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen
        NSLog(@"this is a smaller screen");
        
        importButton.hidden = YES;
        CALayer *btnLayer = [importButton layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setBorderWidth:1.0f];
        [btnLayer setBorderColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1].CGColor];
        [btnLayer setCornerRadius:8.0f];
        
        [importButton setFrame:CGRectMake(55.0, 317.0, 205.0, 36.0)];
        
        [flagButton setFrame:CGRectMake(flagButton.frame.origin.x, 317.0, flagButton.frame.size.width, flagButton.frame.size.height)];
        [categoryPicker setFrame:CGRectMake(categoryPicker.frame.origin.x, 180.0, categoryPicker.frame.size.width, categoryPicker.frame.size.height)];
    }
    else
    {
        importButton.hidden = YES;
        CALayer *btnLayer = [importButton layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setBorderWidth:1.0f];
        [btnLayer setBorderColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1].CGColor];
        [btnLayer setCornerRadius:8.0f];
        
        [importButton setFrame:CGRectMake(55.0, 400.0, 205.0, 36.0)];
        [flagButton setFrame:CGRectMake(flagButton.frame.origin.x, 400.0, flagButton.frame.size.width, flagButton.frame.size.height)];
        [categoryPicker setFrame:CGRectMake(categoryPicker.frame.origin.x, 230.0, categoryPicker.frame.size.width, categoryPicker.frame.size.height)];
    }
    
    // set navbar
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:6.0/255.0 green:79.0/255.0 blue:134.0/255.0 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName :[UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:20.0f]
                                                                      }];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    // Create Unique File Name for GIF
    
    NSString *prefixString = @"GB-GIF";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    
    // get string of url and make sure it works for download
    

}

- (void)viewWillAppear:(BOOL)animated
{
    // RELOAD DATA HERE
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (_importManagedObjectContext == nil)
    {
        _importManagedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
    }
    
    bucketIsFull = @"NO";
    
    // create fetch request for gif image entity
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"GBCategory" inManagedObjectContext:_importManagedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:nil]];
    
    NSError* error = nil;
    NSArray * results = [_importManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // set category array with gifs not at maximum number of gifs
    self.categoryKeys = [[NSMutableArray alloc] init];
    
    for (GBCategory *category in results)
    {
        [categoryKeys addObject:[category categoryName]];
    }
    
    
    // NSLog(@"There are %lu results", (unsigned long)results.count);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < categoryKeys.count; i++)
    {
        NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
        [fetchRequest2 setEntity:[NSEntityDescription entityForName:@"GBGIFImage" inManagedObjectContext:_importManagedObjectContext]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentCategory == %@", categoryKeys[i]];
        [fetchRequest2 setPredicate:predicate];
        

        NSArray *gifObjectArray = [_importManagedObjectContext executeFetchRequest:fetchRequest2 error:nil];
        // NSLog(@"gif object array: %@", gifObjectArray);
        NSMutableArray *gifArray = [[NSMutableArray alloc] init];
        
        for (GBGIFImage *gifObject in gifObjectArray)
        {
            NSString *currentString = [gifObject imageName];
            // NSLog(@"current string %@", currentString);
            [gifArray addObject:currentString];
        }
        
        [dictionary setObject:gifArray forKey:categoryKeys[i]];
    }
    
    gifDictionary = dictionary;
    


    [categoryPicker reloadAllComponents];
    // NSLog(@"category keys: %@", categoryKeys);
    
    // hide back button
    
    // self.navigationItem.hidesBackButton = YES;
    
    // NSString *currentURLString = [urlString absoluteString];
    
    NSLog(@"initial import pasteboard: %@", pstbrd.URL);
    
    pstbrd = [UIPasteboard generalPasteboard];
    NSString *stringly = pstbrd.string;
    NSLog(@"pasteboard stringis currently: %@", pstbrd.string);
    NSString *stringlyHasFormat = @"NO";
    NSString *shortStringly = [stringly substringFromIndex:MAX((int)[stringly length] -3,0)];
    NSLog(@"short stringly is %@", shortStringly);
    
    if ([shortStringly isEqualToString:@"gif"])
    {
        stringlyHasFormat = @"YES";
    }
    
    
    NSString *quickDownloadString = urlDownloadString.absoluteString;
    
    // TODO: get documents directory path to check if gif already exists
    // NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:importGIFPath];
    
    // check to see if the gif is already there and downloaded
    if (fileExists)
    {
        FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:importGIFPath]];
        FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
        theImageView.animatedImage = image;
        
        image = nil;
        
        theImageView.frame = CGRectMake(0.0, 0.0, 234.0, 204.0);
        [self.importedGIFImageView addSubview:theImageView];
    }
    else if (![quickDownloadString isEqualToString:@"placeholder"] && quickDownloadString != nil) {
        NSLog(@"urlstring: %@", urlDownloadString);
        self.downloadMutableData = [[NSMutableData alloc] init];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlDownloadString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
        self.connectionManager = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    }
    else if (urlString != nil)
    {
        NSLog(@"urlstring: %@", urlString);
        self.downloadMutableData = [[NSMutableData alloc] init];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
        self.connectionManager = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    }
    else if ([stringlyHasFormat isEqualToString:@"YES"])
    {
        NSLog(@"Also YES!");
        urlString = [NSURL URLWithString:pstbrd.string];
        NSLog(@"urlstring: %@", urlString);
        self.downloadMutableData = [[NSMutableData alloc] init];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
        self.connectionManager = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    }
    else if([appDelegate receivedGIFURL] != nil)
    {
        NSLog(@"the image is not nil");
        
        self.progressView.hidden = YES;
        // get data from pasteboard
        
        // load data in image view
        
        NSData *data = [NSData dataWithContentsOfURL:[appDelegate receivedGIFURL]];
        FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
        FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
        theImageView.animatedImage = image;
        
        theImageView.frame = CGRectMake(0.0, 0.0, 234.0, 204.0);
        [self.importedGIFImageView addSubview:theImageView];
        
        // Setup GIF file location and save
        
        NSArray *documentsDirectory_1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        importGIFPath = [NSString stringWithFormat:@"%@/%@.gif",documentsDirectory_1, uniqueFileName];
        
        [data writeToFile:importGIFPath atomically:YES];
        
        // temporary data to save to png for thumbnail
        
        UIImage *pngImage = [[UIImage alloc] initWithData:[NSData dataWithData:data]];
        
        NSString *pngFilePath =[NSString stringWithFormat:@"%@/%@.png",documentsDirectory_1, uniqueFileName];
        NSData *pngData = [NSData dataWithData:UIImagePNGRepresentation(pngImage)];
        [pngData writeToFile:pngFilePath atomically:YES];
        
        [appDelegate setReceivedGIFURL:nil];
        
        importButton.hidden = NO;
    }
    else if ([pstbrd dataForPasteboardType:@"com.compuserve.gif"])
    {
        NSLog(@"the image is not nil");
        
        self.progressView.hidden = YES;
        flagButton.hidden = YES;
        // get data from pasteboard
        
        NSData *data = [pstbrd dataForPasteboardType:@"com.compuserve.gif"];
        NSLog(@"data size: %lu", (unsigned long)data.length);
        
        // load data in image view
        
        FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
        FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
        theImageView.animatedImage = image;
        
        theImageView.frame = CGRectMake(0.0, 0.0, 234.0, 204.0);
        [self.importedGIFImageView addSubview:theImageView];
        
        // Setup GIF file location and save
        
        NSArray *documentsDirectory_1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        importGIFPath = [NSString stringWithFormat:@"%@/%@.gif",documentsDirectory_1, uniqueFileName];
        
        [data writeToFile:importGIFPath atomically:YES];
        
        // temporary data to save to png for thumbnail
        
        UIImage *pngImage = [[UIImage alloc] initWithData:[NSData dataWithData:data]];
        
        NSString *pngFilePath =[NSString stringWithFormat:@"%@/%@.png",documentsDirectory_1, uniqueFileName];
        NSData *pngData = [NSData dataWithData:UIImagePNGRepresentation(pngImage)];
        [pngData writeToFile:pngFilePath atomically:YES];
        
        importButton.hidden = NO;
    }
    else
    {
        // NSLog(@"First create a new Bucket");
        UIAlertView *noDataAlert = [[UIAlertView alloc] initWithTitle:@"There is no gif to import!" message:@"\nCopy a gif from another app" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        noDataAlert.alertViewStyle = UIAlertViewStyleDefault;
        
        [noDataAlert show];
        
        [self performSegueWithIdentifier:@"importSegue" sender:self];
    }
    
    wasImportPressed = @"NO";
}

#pragma mark - Load Plist Data and Save to Category

- (void)importButton:(id)sender
{
    
    // Load database and save image name
    
    NSManagedObjectContext *context = [self managedObjectContext];

    // get row number of picker
    NSInteger row = [categoryPicker selectedRowInComponent:0];
    selectedCategory = categoryKeys[row];
    
    // get array of gifs for the purpose of counting
    NSArray *gifCategoryArray = [gifDictionary valueForKey:selectedCategory];
    NSLog(@"There are %lu gifs in %@", (unsigned long)gifCategoryArray.count, selectedCategory);
    
    int maximumBucketSize = 10;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bucketAreLarger"])
    {
        // if users have done the promotion, set maximum size to 15
        maximumBucketSize = 15;
    }
    
    // set imported bool to yes
    if (gifCategoryArray.count < maximumBucketSize || [[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlimited"])
    {
        NSManagedObject *newGBGIF = [NSEntityDescription insertNewObjectForEntityForName:@"GBGIFImage" inManagedObjectContext:context];
        [newGBGIF setValue:uniqueFileName forKey:@"imageName"];
        
        // Set Time Stamp for GIF for later use in Recent GIFs
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        [newGBGIF setValue:dateString forKey:@"timeStamp"];
        
        // Save the URL of the imported GIF from the pasteboard
        
        // pstbrd = [UIPasteboard generalPasteboard];
        // NSURL *url2 = [pstbrd URL];
        // urlString = [url2 absoluteString];
        
        NSString *url2 = [urlString absoluteString];
        
        NSLog(@"URL String is %@", urlString);
        
        [newGBGIF setValue:url2 forKey:@"imageURL"];
        
        // set the remind me later bool for the review function
        
        BOOL campaignOn = NO;
        // (logic is opposite of what it should be but whatever)
        [[NSUserDefaults standardUserDefaults] setBool:campaignOn forKey:@"hitRemindMeLater"];
        
        
        // Set the category of the imported GIF
        
        [newGBGIF setValue:selectedCategory forKeyPath:@"parentCategory"];
        
        NSError *error;
        [context save:&error];
        
        wasImportPressed = @"YES";
        
        // get number of imports
        NSString *numberOfImports = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImports"];
        NSLog(@"current maximum: %@", numberOfImports);
        long i = numberOfImports.integerValue + 1;
        
        NSString *newNumberOfImports = [NSString stringWithFormat:@"%ld", i];
        NSLog(@"new maximum: %@", newNumberOfImports);
        
        [[NSUserDefaults standardUserDefaults] setObject:newNumberOfImports forKey:@"numberOfImports"];
        
        [self performSegueWithIdentifier:@"importSegue" sender:self];
    }
    else
    {
        bucketIsFull = @"YES";
        
        // if bucket is full, show warning
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Looks like you\nneed more space!" message:@"\nChoose a different bucket or get more buckets by clicking + on the Buckets screen" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert dismissWithClickedButtonIndex:1 animated:TRUE];
        [alert show];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([bucketIsFull isEqualToString:@"YES"])
    {
        return NO;
    }
    return YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    NSString *negative = @"NO";
    
    // Check to see if view has changed and import button was not pressed
    // If so, delete the downloaded GIF
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound  && wasImportPressed == negative)
    {
        
        NSError *error;
        // [self.navigationController popViewControllerAnimated:NO];
        NSLog(@"Downloaded GIF will be Deleted and the BOOL is %@", wasImportPressed);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:importGIFPath error:&error];
        if (error) {
            NSLog(@"Deleting the GIF didnt work becuase: %@", error);
        }
    }
    [self.importedGIFImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [super viewWillDisappear:animated];
    [self.view removeFromSuperview];

    
}

#pragma mark - Picker Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [categoryKeys count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return categoryKeys[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    return;
}

#pragma mark - Download and Progress Bar Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%lld", response.expectedContentLength);
    self.urlResponse = response;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.downloadMutableData appendData:data];
    self.progressView.progress = ((100.0/self.urlResponse.expectedContentLength)*self.downloadMutableData.length)/100;
    if (self.progressView.progress == 1) {
        self.progressView.hidden = YES;
    }
    else
    {
        self.progressView.hidden = NO;
    }
    // NSLog(@"%.0f%%", ((100.0/self.urlResponse.expectedContentLength)*self.downloadMutableData.length));
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // NSLog(@"FINISHED");
    
    // Setup GIF file location and save
    
    NSArray *documentsDirectory_1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    importGIFPath = [NSString stringWithFormat:@"%@/%@.gif",documentsDirectory_1, uniqueFileName];
    
    [self.downloadMutableData writeToFile:importGIFPath atomically:YES];
    
    // temporary data to save to png for thumbnail
    
    UIImage *pngImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:importGIFPath]];
    
    NSString *pngFilePath =[NSString stringWithFormat:@"%@/%@.png",documentsDirectory_1, uniqueFileName];
    NSData *pngData = [NSData dataWithData:UIImagePNGRepresentation(pngImage)];
    [pngData writeToFile:pngFilePath atomically:YES];
    
    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:importGIFPath]];
    FLAnimatedImageView *theImageView = [[FLAnimatedImageView alloc] init];
    theImageView.animatedImage = image;
    theImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    image = nil;
    
    theImageView.frame = CGRectMake(0.0, 0.0, 234.0, 204.0);
    [self.importedGIFImageView addSubview:theImageView];
    
    // clear up memory
    
    pngData = nil;
    self.downloadMutableData = nil;
    
    // un-hide import button
    
    importButton.hidden = NO;
    
    // Display imported GIF
}

- (IBAction)flagButton:(id)sender {
    UIAlertView *noDataAlert = [[UIAlertView alloc] initWithTitle:@"Would you like to report this Image?" message:@"\nPlease report any innapropriate gifs or broken links" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Report", nil];
    noDataAlert.alertViewStyle = UIAlertViewStyleDefault;
    
    [noDataAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSLog(@"Report Option Begin");
        
        // email subject
        NSString * subject = @"Gif Bucket Content Report";
        // email body
        NSString * body = [NSString stringWithFormat:@"Please Remove this link from Gif Bucket:\n\n%@", urlString];
        // recipients
        NSArray * recipients = [NSArray arrayWithObjects:@"gifbucketcs@gmail.com", nil];
        
        // create the MFMailComposeViewController
        MFMailComposeViewController * composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        [composer setSubject:subject];
        [composer setMessageBody:body isHTML:NO];
        [composer setToRecipients:recipients];
        
        // present the email on screen
        [self presentViewController:composer animated:YES completion:NULL];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // send category name to bucket collection view
    if([segue.identifier isEqualToString:@"cancelledImport"])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:importGIFPath error:nil];
        NSLog(@"current gif deleted");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"mail saved");
            break;
        case MFMailComposeResultSent:
        {
            UIAlertView *noDataAlert = [[UIAlertView alloc] initWithTitle:@"Thank you" message:@"\nYour report will be reviewed" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            noDataAlert.alertViewStyle = UIAlertViewStyleDefault;
            
            [noDataAlert show];
        }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"mail failed %@", [error localizedDescription]);
            break;
            
        default:
            break;
    }

    NSLog(@"current gif deleted");
    
    // close mail interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // [self.navigationController popViewControllerAnimated:YES];
}
@end
