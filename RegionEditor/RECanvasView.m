//
//  RECanvasView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RECanvasView.h"
#import "NSDictionary+REGeometryExtension.h"

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

- (NSArray<NSDictionary *> *)regions {
    NSMutableArray<NSDictionary *> *regions = [NSMutableArray array];

    for (CALayer *layer in self.layer.sublayers) {
        [regions addObject:[NSDictionary dictionaryWithRect:layer.frame]];
    }

    return regions;
}

- (void)setRegions:(NSArray<NSDictionary *> *)regions {
    NSMutableArray<CALayer *> *sublayers = [NSMutableArray array];
    for (NSDictionary *region in regions) {
        CALayer *layer = [[CALayer alloc] init];
        layer.borderColor = NSColor.redColor.CGColor;
        layer.borderWidth = 1.0;
        layer.frame = region.rectValue;

        [sublayers addObject:layer];
    }
    self.layer.sublayers = sublayers;
}

@end

NS_ASSUME_NONNULL_END
