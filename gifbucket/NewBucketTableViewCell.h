//
//  NewBucketTableViewCell.h
//  GIFBucket
//
//  Created by Brown, Jon on 10/1/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewBucketTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bucketIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

- (IBAction)purchaseButton:(id)sender;

@end
