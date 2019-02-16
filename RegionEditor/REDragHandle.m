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

@interface NSCursor ()

// TODO: Avoid using a private API; create custom resize cursors.

@property (nonatomic, readonly, class) NSCursor *_windowResizeEastCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeEastWestCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthEastCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthEastSouthWestCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthSouthCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthWestCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthWestSouthEastCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeSouthCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeSouthEastCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeSouthWestCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeWestCursor;

@end

@interface REDragHandle ()

@property (nonatomic, nullable) NSCursor *cursor;

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

- (void)mouseDragged:(NSEvent *)event {
    NSView *regionView = self.superview;
    NSView *canvasView = regionView.superview;

    NSPoint p = [canvasView convertPoint:event.locationInWindow fromView:nil];
    NSRect frame = regionView.frame;

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

    regionView.frame = NSIntersectionRect(NSIntegralRect(frame), canvasView.bounds);
}

- (void)mouseUp:(NSEvent *)event {
    [NSApp sendAction:NSSelectorFromString(@"resize:") to:nil from:self.superview];
}

- (void)setDragAction:(REDragAction)dragAction {
    _dragAction = dragAction;

    if (dragAction & REDragMinX) {
        if (dragAction & REDragMinY) {
            _cursor = NSCursor._windowResizeNorthWestSouthEastCursor;
        }
        else if (dragAction & REDragMaxY) {
            _cursor = NSCursor._windowResizeNorthEastSouthWestCursor;
        }
        else {
            _cursor = NSCursor._windowResizeEastWestCursor;
        }
    }
    else if (dragAction & REDragMaxX) {
        if (dragAction & REDragMinY) {
            _cursor = NSCursor._windowResizeNorthEastSouthWestCursor;
        }
        else if (dragAction & REDragMaxY) {
            _cursor = NSCursor._windowResizeNorthWestSouthEastCursor;
        }
        else {
            _cursor = NSCursor._windowResizeEastWestCursor;
        }
    }
    else if (dragAction) {
        _cursor = NSCursor._windowResizeNorthSouthCursor;
    }
}

@end

NS_ASSUME_NONNULL_END
