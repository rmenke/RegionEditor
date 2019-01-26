//
//  RERegion.m
//  RegionEditor
//
//  Created by Rob Menke on 1/26/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RERegion.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RERegion

- (nullable instancetype)init {
    return self = [self initWithRect:NSZeroRect];
}

- (nullable instancetype)initWithRect:(NSRect)rect {
    self = [super init];
    if (self) {
        _minX = NSMinX(rect);
        _minY = NSMinY(rect);
        _maxX = NSMaxX(rect);
        _maxY = NSMaxY(rect);
    }
    return self;
}

- (CGFloat)midX {
    return (_minX + _maxX) / 2.0;
}

+ (NSSet *)keyPathsForValuesAffectingMidX {
    return [NSSet setWithObjects:@"minX", @"maxX", nil];
}

- (CGFloat)midY {
    return (_minY + _maxY) / 2.0;
}

+ (NSSet *)keyPathsForValuesAffectingMidY {
    return [NSSet setWithObjects:@"minY", @"maxY", nil];
}

- (NSRect)rectValue {
    return NSMakeRect(_minX, _minY, _maxX - _minX, _maxY - _minY);
}

- (void)setRectValue:(NSRect)rect {
    self.minX = NSMinX(rect);
    self.minY = NSMinY(rect);
    self.maxX = NSMaxX(rect);
    self.maxY = NSMaxY(rect);
}

+ (NSSet *)keyPathsForValuesAffectingRectValue {
    return [NSSet setWithObjects:@"minX", @"minY", @"maxX", @"maxY", nil];
}

@end

NS_ASSUME_NONNULL_END
