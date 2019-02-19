//
//  REDragHandle.h
//  RegionEditor
//
//  Created by Rob Menke on 1/27/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

@import Cocoa;

typedef NS_OPTIONS(NSUInteger, REDragAction) {
    REDragMinX = 1 << 0,
    REDragMinY = 1 << 1,
    REDragMaxX = 1 << 2,
    REDragMaxY = 1 << 3
};

NS_ASSUME_NONNULL_BEGIN

@interface REDragHandle : NSView

@property (nonatomic) REDragAction dragAction;
@property (nonatomic, nullable) NSCursor *cursor;

@end

NS_ASSUME_NONNULL_END
