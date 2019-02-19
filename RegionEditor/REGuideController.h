//
//  RESnapController.h
//  RegionEditor
//
//  Created by Rob Menke on 2/17/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

@import Foundation;

@class NSView;
@class CAShapeLayer;

NS_ASSUME_NONNULL_BEGIN

@interface REGuideController : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(NSView *)view
         addHorizontalGuides:(BOOL)horizontal
           addVerticalGuides:(BOOL)vertical
            excludingSubview:(nullable NSView *)subview NS_DESIGNATED_INITIALIZER;

- (NSPoint)snapToGuides:(NSPoint)point NS_SWIFT_NAME(snapToGuides(point:));

- (void)hideGuides;

@end

NS_ASSUME_NONNULL_END
