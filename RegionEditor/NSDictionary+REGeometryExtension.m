//
//  NSDictionary+REGeometryExtension.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "NSDictionary+REGeometryExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDictionary (REGeometryExtension)

- (instancetype)initWithRect:(NSRect)rect {
    NSNumber *minX = @(NSMinX(rect));
    NSNumber *minY = @(NSMinY(rect));
    NSNumber *maxX = @(NSMaxX(rect));
    NSNumber *maxY = @(NSMaxY(rect));

    return self = [self initWithObjectsAndKeys:minX, @"minX", minY, @"minY", maxX, @"maxX", maxY, @"maxY", nil];
}

+ (instancetype)dictionaryWithRect:(NSRect)rect {
    return [[self alloc] initWithRect:rect];
}

- (NSRect)rectValue {
    CGFloat minX = [self[@"minX"] doubleValue];
    CGFloat minY = [self[@"minY"] doubleValue];
    CGFloat maxX = [self[@"maxX"] doubleValue];
    CGFloat maxY = [self[@"maxY"] doubleValue];

    return NSMakeRect(minX, minY, maxX - minX, maxY - minY);
}

@end

@implementation NSMutableDictionary (REGeometryExtension)

- (void)setRectValue:(NSRect)rectValue {
    self[@"minX"] = @(NSMinX(rectValue));
    self[@"minY"] = @(NSMinY(rectValue));
    self[@"maxX"] = @(NSMaxX(rectValue));
    self[@"maxY"] = @(NSMaxY(rectValue));
}

@end

NS_ASSUME_NONNULL_END
