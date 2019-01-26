//
//  RERegion.h
//  RegionEditor
//
//  Created by Rob Menke on 1/26/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface RERegion : NSObject

@property (nonatomic) CGFloat minX, minY, maxX, maxY;
@property (nonatomic, readonly) CGFloat midX, midY;
@property (nonatomic) NSRect rectValue;

- (nullable instancetype)initWithRect:(NSRect)rect NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
