//
//  REGuideController.m
//  RegionEditor
//
//  Created by Rob Menke on 2/17/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "REGuideController.h"

@import AppKit;
@import QuartzCore;

#define MAX_SNAP_RADIUS 3
#define DIST(A, B) ({ __typeof(A) __a = (A); __typeof(B) __b = (B); __a > __b ? __a - __b : __b - __a; })
#define CLAMP(X, LO, HI) MAX(LO, MIN(HI, X))

static NSUInteger snapToGuide(NSIndexSet *guides, NSUInteger value) {
    __block NSUInteger snap = NSNotFound;

    // These gymnastics prevent the range from wrapping around which can break
    // +[NSIndexSet enumerateIndexesInRange:usingBlock:].

    NSUInteger radius = MIN(value, MAX_SNAP_RADIUS);
    NSRange range = NSMakeRange(value - radius, radius + MAX_SNAP_RADIUS + 1);

    [guides enumerateIndexesInRange:range options:0 usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        if (DIST(snap, value) > DIST(idx, value)) {
            snap = idx;
            *stop = (snap == value);
        }
    }];

    return snap;
}

@interface REGuideController ()

@property (nonatomic, weak) CAShapeLayer *layer;

@property (nonatomic, nullable) NSMutableIndexSet *horizontalGuides;
@property (nonatomic, nullable) NSMutableIndexSet *verticalGuides;

@property (nonatomic) NSRect bounds;

@end

@implementation REGuideController

- (instancetype)initWithView:(NSView *)view
         addHorizontalGuides:(BOOL)horizontal
           addVerticalGuides:(BOOL)vertical
            excludingSubview:(NSView *)skippedView {
    self = [super init];

    if (self) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        
        layer.zPosition = 100.0;
        layer.lineWidth = 2.0;
        layer.lineDashPattern = @[@3, @5];
        layer.strokeColor = NSColor.redColor.CGColor;
        layer.fillColor = nil;

        CABasicAnimation *animation = [CABasicAnimation animation];

        animation.repeatCount = INFINITY;
        animation.fromValue = @16;
        animation.toValue = @0;
        animation.duration = 1.0;

        [layer addAnimation:animation forKey:@"lineDashPhase"];

        [view.layer addSublayer:layer];

        _layer = layer;

        _bounds = view.bounds;

        if (horizontal) _horizontalGuides = [NSMutableIndexSet indexSet];
        if (vertical)   _verticalGuides   = [NSMutableIndexSet indexSet];

        for (NSView *subview in view.subviews) {
            if (subview == skippedView) continue;

            NSRect frame = subview.frame;

            [_horizontalGuides addIndex:NSMinY(frame)];
            [_horizontalGuides addIndex:NSMaxY(frame)];
            [_verticalGuides   addIndex:NSMinX(frame)];
            [_verticalGuides   addIndex:NSMaxX(frame)];
        }
    }

    return self;
}

- (void)dealloc {
    [_layer removeFromSuperlayer];
}

- (NSPoint)snapToGuides:(NSPoint)point {
    NSUInteger x = CLAMP(lround(point.x), NSMinX(_bounds), NSMaxX(_bounds));
    NSUInteger y = CLAMP(lround(point.y), NSMinY(_bounds), NSMaxY(_bounds));

    CGMutablePathRef path = CGPathCreateMutable();

    if (_verticalGuides) {
        NSUInteger xSnap = snapToGuide(_verticalGuides, x);

        if (xSnap != NSNotFound) {
            x = xSnap;

            CGPathMoveToPoint(path, NULL, x, NSMinY(_bounds));
            CGPathAddLineToPoint(path, NULL, x, NSMaxY(_bounds));
        }
    }

    if (_horizontalGuides) {
        NSUInteger ySnap = snapToGuide(_horizontalGuides, y);

        if (ySnap != NSNotFound) {
            y = ySnap;

            CGPathMoveToPoint(path, NULL, NSMinX(_bounds), y);
            CGPathAddLineToPoint(path, NULL, NSMaxX(_bounds), y);
        }
    }

    _layer.path = path;

    CGPathRelease(path);

    return NSMakePoint(x, y);
}

- (void)hideGuides {
    _layer.path = nil;
}

@end

