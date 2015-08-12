//
//  DebugView.m
//  FLAnimatedImageDemo
//
//  Created by Raphael Schaad on 4/1/14.
//  Copyright (c) 2014 Flipboard. All rights reserved.
//


#import "DebugView.h"
#import "RSPlayPauseButton.h"


@interface DebugView ()

@property (nonatomic, strong) RSPlayPauseButton *playPauseButton;

@end


@implementation DebugView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = DebugViewStyleDefault;
    }
    return self;
}


- (void)setStyle:(DebugViewStyle)style
{
    if (_style != style)
    {
        _style = style;
        [self setNeedsLayout];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat kMargin = 10.0;
    
    if (!self.playPauseButton) {
        self.playPauseButton = [[RSPlayPauseButton alloc] init];
        self.playPauseButton.paused = NO;
        CGRect frame = self.playPauseButton.frame;
        frame.origin = CGPointMake(CGRectGetMaxX(self.bounds) - frame.size.width - kMargin, CGRectGetMaxY(self.bounds) - frame.size.height - kMargin);
        self.playPauseButton.frame = frame;
        self.playPauseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        self.playPauseButton.color = [UIColor colorWithRed:0.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:.5];
        [self.playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playPauseButton];
    }
    
}


#pragma mark - Play/Pause Action

- (void)playPauseButtonPressed:(RSPlayPauseButton *)playPauseButton
{
    if (self.playPauseButton.isPaused) {
        [self.playPauseButton setPaused:NO animated:YES];
        [self.imageView startAnimating];
    } else {
        [self.playPauseButton setPaused:YES animated:YES];
        [self.imageView stopAnimating];
    }
}



@end
