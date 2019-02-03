//
//  RECanvasView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

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

- (NSArray<NSValue *> *)regions {
    NSMutableArray<NSValue *> *regions = [NSMutableArray array];

    for (NSView *subview in self.subviews) {
        [regions addObject:[NSValue valueWithRect:subview.frame]];
    }

    return regions;
}

- (void)setRegions:(NSArray<NSValue *> *)regions {
    const NSUInteger count = regions.count;

    NSMutableArray<__kindof NSView *> *subviews = self.subviews.mutableCopy;

    while (subviews.count < count) {
        [subviews addObject:[[RERegionView alloc] initWithFrame:NSZeroRect]];
    }
    while (subviews.count > count) {
        [subviews removeLastObject];
    }

    for (NSUInteger index = 0; index < count; ++index) {
        [subviews[index] setIntegerValue:(index + 1)];
        subviews[index].frame = regions[index].rectValue;
    }

    if (count) {
        for (NSUInteger index = 1; index < count; ++index) {
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

    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        id responder = index != NSNotFound && index < self.subviews.count ? self.subviews[index] : nil;
        [self.window makeFirstResponder:responder];
    }];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionIndexes {
    return [NSSet setWithObject:@"window.firstResponder"];
}

@end

NS_ASSUME_NONNULL_END
