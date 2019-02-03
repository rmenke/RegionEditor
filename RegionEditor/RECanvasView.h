//
//  RECanvasView.h
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

@interface RECanvasView : NSView

@property (nonatomic, nonnull, copy) NSArray<NSValue *> *regions;
@property (nonatomic, nonnull, copy) NSIndexSet *selectionIndexes;

- (void)setImage:(NSImage *)image;

@end

NS_ASSUME_NONNULL_END
