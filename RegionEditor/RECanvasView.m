//
//  RECanvasView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RECanvasView.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RECanvasView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    self.wantsLayer = YES;
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)setImage:(NSImage *)image {
    CGFloat scale = [image recommendedLayerContentsScale:0.0];
    self.layer.contents = [image layerContentsForContentsScale:scale];
}

@end

NS_ASSUME_NONNULL_END
