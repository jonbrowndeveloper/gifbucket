//
//  BucketGIFImageViewController.h
//  GIFBucket
//
//  Created by Brown, Jon on 8/25/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsfireSDK.h"
#import "AppsfireAdSDK.h"
#import "FLAnimatedImageView.h"

@interface BucketGIFImageViewController : UIViewController
{
    bool appLovinVideoLoaded;
}
@property (nonatomic, retain) NSString *currentGIFImage;
- (IBAction)trashButton:(id)sender;

@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic, retain) NSString *filePath;
- (IBAction)freeGameButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *freeGameButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *removeAdsButtonOutlet;
- (IBAction)removeAdsButtonAction:(id)sender;

@property (assign, atomic, getter=isVideoAvailible) BOOL videoAvailible;

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *gifImageView;

@end
