//
//  GBCollectionViewCell.m
//  gifbucket
//
//  Created by Steve Brown on 9/2/15.
//  Copyright (c) 2015 JonBrown. All rights reserved.
//

#import "GBCollectionViewCell.h"

@implementation GBCollectionViewCell

@synthesize imageView;

- (void)awakeFromNib
{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@end
