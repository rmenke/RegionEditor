//
//  RERegionView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/22/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RERegionView.h"
#import "REDragHandle.h"

NS_ASSUME_NONNULL_BEGIN

const CGFloat SIZE = 10.0;

@interface NSCursor ()

// TODO: Avoid using a private API; create custom resize cursors.

@property (nonatomic, readonly, class) NSCursor *_windowResizeEastWestCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthEastSouthWestCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthSouthCursor;
@property (nonatomic, readonly, class) NSCursor *_windowResizeNorthWestSouthEastCursor;

@end

@interface RERegionView ()

@property (nonatomic, nonnull) NSTextField *label;

@end

@implementation RERegionView {
    REDragHandle *dragHandle[8];
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.borderColor = NSColor.redColor.CGColor;
        self.layer.backgroundColor = [NSColor.redColor colorWithAlphaComponent:0.10].CGColor;
        self.layer.borderWidth = 1.0;

        self.label = [[NSTextField alloc] initWithFrame:NSZeroRect];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.editable = NO;
        self.label.bordered = NO;
        self.label.textColor = NSColor.whiteColor;
        self.label.backgroundColor = NSColor.redColor;
        self.label.font = [NSFont boldSystemFontOfSize:0];

        [self addSubview:self.label];
        [self.label.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.label.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;

        for (int i = 0; i < 8; ++i) {
            dragHandle[i] = [[REDragHandle alloc] initWithFrame:NSZeroRect];
            dragHandle[i].hidden = YES;
            dragHandle[i].translatesAutoresizingMaskIntoConstraints = NO;

            [self addSubview:dragHandle[i]];
        }

        [dragHandle[0].topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [dragHandle[0].leftAnchor constraintEqualToAnchor:self.leftAnchor constant:SIZE].active = YES;
        [dragHandle[0].rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-SIZE].active = YES;
        [dragHandle[0].heightAnchor constraintEqualToConstant:SIZE].active = YES;

        [dragHandle[1].topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [dragHandle[1].rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [dragHandle[1].widthAnchor constraintEqualToConstant:SIZE].active = YES;
        [dragHandle[1].heightAnchor constraintEqualToConstant:SIZE].active = YES;

        [dragHandle[2].topAnchor constraintEqualToAnchor:self.topAnchor constant:SIZE].active = YES;
        [dragHandle[2].bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-SIZE].active = YES;
        [dragHandle[2].rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [dragHandle[2].widthAnchor constraintEqualToConstant:SIZE].active = YES;

        [dragHandle[3].bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [dragHandle[3].rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [dragHandle[3].widthAnchor constraintEqualToConstant:SIZE].active = YES;
        [dragHandle[3].heightAnchor constraintEqualToConstant:SIZE].active = YES;

        [dragHandle[4].bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [dragHandle[4].leftAnchor constraintEqualToAnchor:self.leftAnchor constant:SIZE].active = YES;
        [dragHandle[4].rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-SIZE].active = YES;
        [dragHandle[4].heightAnchor constraintEqualToConstant:SIZE].active = YES;

        [dragHandle[5].bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [dragHandle[5].leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [dragHandle[5].widthAnchor constraintEqualToConstant:SIZE].active = YES;
        [dragHandle[5].heightAnchor constraintEqualToConstant:SIZE].active = YES;

        [dragHandle[6].topAnchor constraintEqualToAnchor:self.topAnchor constant:SIZE].active = YES;
        [dragHandle[6].bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-SIZE].active = YES;
        [dragHandle[6].leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [dragHandle[6].widthAnchor constraintEqualToConstant:SIZE].active = YES;

        [dragHandle[7].topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [dragHandle[7].leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [dragHandle[7].widthAnchor constraintEqualToConstant:SIZE].active = YES;
        [dragHandle[7].heightAnchor constraintEqualToConstant:SIZE].active = YES;

        dragHandle[0].dragAction = REDragMinY;
        dragHandle[1].dragAction = REDragMaxX | REDragMinY;
        dragHandle[2].dragAction = REDragMaxX;
        dragHandle[3].dragAction = REDragMaxX | REDragMaxY;
        dragHandle[4].dragAction = REDragMaxY;
        dragHandle[5].dragAction = REDragMinX | REDragMaxY;
        dragHandle[6].dragAction = REDragMinX;
        dragHandle[7].dragAction = REDragMinX | REDragMinY;

        dragHandle[0].cursor = [NSCursor _windowResizeNorthSouthCursor];
        dragHandle[1].cursor = [NSCursor _windowResizeNorthEastSouthWestCursor];
        dragHandle[2].cursor = [NSCursor _windowResizeEastWestCursor];
        dragHandle[3].cursor = [NSCursor _windowResizeNorthWestSouthEastCursor];
        dragHandle[4].cursor = [NSCursor _windowResizeNorthSouthCursor];
        dragHandle[5].cursor = [NSCursor _windowResizeNorthEastSouthWestCursor];
        dragHandle[6].cursor = [NSCursor _windowResizeEastWestCursor];
        dragHandle[7].cursor = [NSCursor _windowResizeNorthWestSouthEastCursor];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    self.layer.borderWidth = 2.0;
    for (int i = 0; i < 8; ++i) dragHandle[i].hidden = NO;
    return YES;
}

- (BOOL)resignFirstResponder {
    self.layer.borderWidth = 1.0;
    for (int i = 0; i < 8; ++i) dragHandle[i].hidden = YES;
    return YES;
}

- (NSInteger)integerValue {
    return self.label.integerValue;
}

- (void)setIntegerValue:(NSInteger)integerValue {
    self.label.integerValue = integerValue;
    [self.label sizeToFit];
}

@end

NS_ASSUME_NONNULL_END
