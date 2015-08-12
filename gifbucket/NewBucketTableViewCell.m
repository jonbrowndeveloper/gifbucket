//
//  NewBucketTableViewCell.m
//  GIFBucket
//
//  Created by Brown, Jon on 10/1/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "NewBucketTableViewCell.h"

@implementation NewBucketTableViewCell

@synthesize titleLabel, descriptionLabel, bucketIconImageView, priceLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)purchaseButton:(id)sender
{
    
}
@end
