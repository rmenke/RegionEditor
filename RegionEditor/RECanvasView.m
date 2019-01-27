//
//  RECanvasView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RERegion.h"
#import "RECanvasView.h"
#import "RERegionView.h"

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

- (NSArray<RERegion *> *)regions {
    NSMutableArray<RERegion *> *regions = [NSMutableArray array];

    for (NSView *subview in self.subviews) {
        [regions addObject:[[RERegion alloc] initWithRect:subview.frame]];
    }

    return regions;
}

- (void)setRegions:(NSArray<RERegion *> *)regions {
    NSMutableArray<__kindof NSView *> *subviews = [NSMutableArray arrayWithCapacity:regions.count];

    for (RERegion *region in regions) {
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

- (NSIndexSet *)selectionIndexes {
    id responder = self.window.firstResponder;
    NSUInteger index = [self.subviews indexOfObjectIdenticalTo:responder];
    return index != NSNotFound ? [NSIndexSet indexSetWithIndex:index] : [NSIndexSet indexSet];
}

- (void)setSelectionIndexes:(NSIndexSet *)selectionIndexes {
    NSUInteger index = selectionIndexes.firstIndex;
    id responder = index != NSNotFound ? self.subviews[index] : nil;
    [self.window makeFirstResponder:responder];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionIndexes {
    return [NSSet setWithObject:@"window.firstResponder"];
}

@end

NS_ASSUME_NONNULL_END
