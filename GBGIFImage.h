//
//  GBGIFImage.h
//  GIFBucket
//
//  Created by Brown, Jon on 10/3/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GBGIFImage : NSManagedObject

@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * parentCategory;
@property (nonatomic, retain) NSString * timeStamp;

@end
