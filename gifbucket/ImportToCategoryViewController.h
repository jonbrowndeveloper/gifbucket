//
//  ImportToCategoryViewController.h
//  GIFBucket
//
//  Created by Brown, Jon on 7/24/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ImportToCategoryViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, NSURLConnectionDataDelegate, MFMailComposeViewControllerDelegate>
{
    UIPasteboard *pstbrd;
}



@property (nonatomic, strong) NSManagedObjectContext *importManagedObjectContext;


- (IBAction)importButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (strong, nonatomic) IBOutlet UIImageView *importedGIFImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, retain) NSMutableDictionary *importCategories;
@property (nonatomic, retain) NSMutableArray *categoryKeys;
@property (nonatomic, retain) NSString *uniqueFileName;
@property (nonatomic, retain) NSString *importGIFPath;

@property (nonatomic, strong) NSURLConnection *connectionManager;
@property (nonatomic, strong) NSMutableData *downloadMutableData;
@property (nonatomic, strong) NSURLResponse *urlResponse;

@property (nonatomic, retain) NSString *wasImportPressed;
@property (nonatomic, retain) NSString *selectedCategory;

@property (nonatomic, retain) NSMutableDictionary *gifDictionary;
@property (nonatomic, retain) NSURL *urlString;
@property (nonatomic, retain) NSURL *urlDownloadString;
@property (nonatomic, retain) NSString *bucketIsFull;

- (IBAction)flagButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *flagButton;

@end
