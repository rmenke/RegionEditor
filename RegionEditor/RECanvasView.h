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

@property (nonatomic, nonnull) NSArray<NSDictionary<NSString *, NSNumber *> *> *regions;

- (void)setImage:(NSImage *)image;

@end

NS_ASSUME_NONNULL_END
