//
//  GBCollectionViewCell.h
//  gifbucket
//
//  Created by Steve Brown on 9/2/15.
//  Copyright (c) 2015 JonBrown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@interface GBCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageView;

@end
