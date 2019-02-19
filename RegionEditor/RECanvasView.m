//
//  RECanvasView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RECanvasView.h"
#import "RERegionView.h"
#import "REGuideController.h"

@import QuartzCore;

NS_ASSUME_NONNULL_BEGIN

@interface RECanvasView ()

@property (nonatomic, readonly) NSRect rectValue;

@end

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

    NSMutableArray<RERegionView *> *subviews = self.subviews.mutableCopy;

    while (subviews.count < count) {
        [subviews addObject:[[RERegionView alloc] initWithFrame:NSZeroRect]];
    }
    while (subviews.count > count) {
        [subviews removeLastObject];
    }

    for (NSUInteger index = 0; index < count; ++index) {
        subviews[index].integerValue = index + 1;
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

- (void)mouseDown:(NSEvent *)event {
    REGuideController *guideController =
        [[REGuideController alloc] initWithView:self addHorizontalGuides:YES addVerticalGuides:YES excludingSubview:nil];

    // Cannot use NSRect because it has problems with negative widths/heights.
    // CoreGraphics is fine with them, and it makes keeping track of the origin point easy.
    CGRect r = { .origin = NSPointToCGPoint([self convertPoint:event.locationInWindow fromView:nil]), .size = CGSizeZero };

    if (~event.modifierFlags & NSEventModifierFlagOption) {
        r.origin = [guideController snapToGuides:r.origin];
    }

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = NSColor.redColor.CGColor;
    layer.fillColor = [NSColor.redColor colorWithAlphaComponent:0.10].CGColor;

    [self.layer addSublayer:layer];

    CGRect bounds = NSRectToCGRect(self.bounds);

    do {
        event = [self.window nextEventMatchingMask:NSEventMaskLeftMouseUp|NSEventMaskLeftMouseDragged];
        NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];

        if (~event.modifierFlags & NSEventModifierFlagOption) {
            point = [guideController snapToGuides:point];
        }
        else {
            [guideController hideGuides];
        }

        r.size = CGSizeMake(point.x - r.origin.x, point.y - r.origin.y);

        if (event.type == NSEventTypeLeftMouseDragged) {
            CGPathRef path = CGPathCreateWithRect(CGRectIntersection(r, bounds), NULL);
            layer.path = path;
            CGPathRelease(path);
        }
    } while (event.type != NSEventTypeLeftMouseUp);

    r = CGRectIntegral(r);

    if (r.size.width >= 50 && r.size.height >= 50) {
        _rectValue = NSRectFromCGRect(r);
        [NSApp sendAction:@selector(add:) to:nil from:self];
    }

    [layer removeFromSuperlayer];
}

@end

NS_ASSUME_NONNULL_END
