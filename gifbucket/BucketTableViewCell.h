//
//  BucketTableViewCell.h
//  GIFBucket
//
//  Created by Brown, Jon on 7/22/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BucketTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *tableViewImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellCountLabel;

@end
