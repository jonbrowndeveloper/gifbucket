//
//  GifBucketIAPHelper.m
//  GIFBucket
//
//  Created by JB on 9/14/14.
//  Copyright (c) 2014 JonBrown. All rights reserved.
//

#import "GifBucketIAPHelper.h"

@implementation GifBucketIAPHelper

+ (GifBucketIAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static GifBucketIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                     @"com.jonbrown.GifBucket.singlebucket1",
                                     @"com.jonbrown.GifBucket.bucketbundle5",
                                     @"com.jonbrown.GifBucket.gifbucketunlimited", nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
