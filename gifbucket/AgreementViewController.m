//
//  AgreementViewController.m
//  GIFBucket
//
//  Created by JB on 11/9/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "AgreementViewController.h"

@interface AgreementViewController ()

@end

@implementation AgreementViewController

@synthesize button, textView, bucketLogo;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    bucketLogo.image = [UIImage imageNamed:@"gifbucket-title-original-blue60.png"];
  
    if ((int)[[UIScreen mainScreen] bounds].size.height == 480)
    {
        // This is iPhone 4/4s screen
        NSLog(@"this is a smaller screen");
        
        CGRect oldFrame2 = textView.frame;
        CGRect newFrame2 = CGRectMake(oldFrame2.origin.x, oldFrame2.origin.y, oldFrame2.size.width, oldFrame2.size.height - 100);
        textView.frame = newFrame2;
        
        CGRect oldFrame3 = button.frame;
        CGRect newFrame3 = CGRectMake(oldFrame3.origin.x, oldFrame3.origin.y - 100, oldFrame3.size.width, oldFrame3.size.height);
        button.frame = newFrame3;
    }
}



@end
