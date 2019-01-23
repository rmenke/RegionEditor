//
//  RECanvasView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RECanvasView.h"
#import "RERegionView.h"
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

    for (NSView *subview in self.subviews) {
        [regions addObject:[NSDictionary dictionaryWithRect:subview.frame]];
    }

    return regions;
}

- (void)setRegions:(NSArray<NSDictionary *> *)regions {
    NSMutableArray<__kindof NSView *> *subviews = [NSMutableArray arrayWithCapacity:regions.count];

    for (NSDictionary *region in regions) {
        RERegionView *regionView = [[RERegionView alloc] initWithFrame:region.rectValue];
        [subviews addObject:regionView];
    }

    if (subviews.count) {
        for (NSUInteger index = 1; index < subviews.count; ++index) {
            subviews[index - 1].nextKeyView = subviews[index];
        }
        subviews.lastObject.nextKeyView = subviews.firstObject;
        self.window.initialFirstResponder = subviews.firstObject;
    }

    self.subviews = subviews;
}

@end

NS_ASSUME_NONNULL_END
