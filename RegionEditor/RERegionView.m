//
//  RERegionView.m
//  RegionEditor
//
//  Created by Rob Menke on 1/22/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "RERegionView.h"

@implementation RERegionView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.borderColor = NSColor.redColor.CGColor;
        self.layer.borderWidth = 1.0;
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
    return YES;
}

- (BOOL)resignFirstResponder {
    self.layer.borderWidth = 1.0;
    return YES;
}

@end
