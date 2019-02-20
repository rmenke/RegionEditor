//
//  REDragHandle.m
//  RegionEditor
//
//  Created by Rob Menke on 1/27/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "REDragHandle.h"
#import "RERegionView.h"
#import "REGuideController.h"

NS_ASSUME_NONNULL_BEGIN

@interface REDragHandle ()

@end

@implementation REDragHandle

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect|NSTrackingCursorUpdate owner:self userInfo:nil]];
    }
    return self;
}

- (void)cursorUpdate:(NSEvent *)event {
    if (_cursor) [_cursor set];
}

- (void)mouseDown:(NSEvent *)event {
    NSView *regionView = self.superview;
    NSView *canvasView = regionView.superview;

    BOOL dragMinX = _dragAction & REDragMinX;
    BOOL dragMinY = _dragAction & REDragMinY;
    BOOL dragMaxX = _dragAction & REDragMaxX;
    BOOL dragMaxY = _dragAction & REDragMaxY;

    REGuideController *guideController =
        [[REGuideController alloc] initWithView:canvasView
                            addHorizontalGuides:(dragMinY||dragMaxY)
                              addVerticalGuides:(dragMinX||dragMaxX)
                               excludingSubview:regionView];

    do {
        event = [self.window nextEventMatchingMask:NSEventMaskLeftMouseUp|NSEventMaskLeftMouseDragged];

        if (event.type == NSEventTypeLeftMouseDragged) {
            NSPoint point = [canvasView convertPoint:event.locationInWindow fromView:nil];

            point = [guideController snapToGuides:point forEvent:event];

            NSRect frame = regionView.frame;

            CGFloat minX = NSMinX(frame);
            CGFloat minY = NSMinY(frame);
            CGFloat maxX = NSMaxX(frame);
            CGFloat maxY = NSMaxY(frame);

            if (dragMinX) {
                minX = MIN(point.x, maxX - 50.0);
            }
            else if (dragMaxX) {
                maxX = MAX(point.x, minX + 50.0);
            }
            if (dragMinY) {
                minY = MIN(point.y, maxY - 50.0);
            }
            else if (dragMaxY) {
                maxY = MAX(point.y, minY + 50.0);
            }

            regionView.frame = NSIntersectionRect(NSIntegralRect(NSMakeRect(minX, minY, maxX - minX, maxY - minY)), canvasView.bounds);
        }
    } while (event.type != NSEventTypeLeftMouseUp);

    [NSApp sendAction:NSSelectorFromString(@"resize:") to:nil from:self.superview];
}

@end

NS_ASSUME_NONNULL_END
