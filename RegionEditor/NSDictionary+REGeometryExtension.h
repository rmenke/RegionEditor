//
//  NSDictionary+REGeometryExtension.h
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (REGeometryExtension)

- (instancetype)initWithRect:(NSRect)rect;
+ (instancetype)dictionaryWithRect:(NSRect)rect;

@property (nonatomic, readonly) NSRect rectValue;

@end

@interface NSMutableDictionary (REGeometryExtension)

@property (nonatomic, readwrite) NSRect rectValue;

@end
