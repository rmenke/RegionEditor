//
//  REDragHandle.m
//  RegionEditor
//
//  Created by Rob Menke on 1/27/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "REDragHandle.h"
#import "RERegionView.h"

NS_ASSUME_NONNULL_BEGIN

#define REDragX (REDragMinX | REDragMaxX)
#define REDragY (REDragMinY | REDragMaxY)

@implementation REDragHandle {
    NSRect originalFrame;
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingActiveInKeyWindow|NSTrackingInVisibleRect|NSTrackingCursorUpdate owner:self userInfo:nil]];
    }
    return self;
}

- (void)cursorUpdate:(NSEvent *)event {
    [[NSCursor crosshairCursor] set];
}

- (void)mouseDown:(NSEvent *)event {
    originalFrame = self.superview.frame;
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint p = [self.superview.superview convertPoint:event.locationInWindow fromView:nil];
    NSRect frame = self.superview.frame;

    CGFloat minX = NSMinX(frame);
    CGFloat minY = NSMinY(frame);
    CGFloat maxX = NSMaxX(frame);
    CGFloat maxY = NSMaxY(frame);

    if (self.dragAction & REDragMinX) {
        frame.size.width = MAX(maxX - p.x, 50);
        frame.origin.x = MIN(maxX - 50, p.x);
    }

    if (self.dragAction & REDragMinY) {
        frame.size.height = MAX(maxY - p.y, 50);
        frame.origin.y = MIN(maxY - 50, p.y);
    }

    if (self.dragAction & REDragMaxX) {
        frame.size.width = MAX(p.x - minX, 50);
    }

    if (self.dragAction & REDragMaxY) {
        frame.size.height = MAX(p.y - minY, 50);
    }

    self.superview.frame = frame;
}

- (void)mouseUp:(NSEvent *)event {
    [NSApp sendAction:NSSelectorFromString(@"resize:") to:nil from:self.superview];
}

@end

NS_ASSUME_NONNULL_END
