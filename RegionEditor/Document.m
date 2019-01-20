//
//  Document.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "Document.h"
#import "RECanvasView.h"
#import "NSDictionary+REGeometryExtension.h"

@import Darwin.POSIX.sys.xattr;

NS_ASSUME_NONNULL_BEGIN

const char *const REGION_XATTR_NAME = "com.the-wabe.regions";

static NSPoint topLeft;

@interface Document ()

@property (nonatomic) NSImage *image;
@property (nonatomic, nonnull) NSMutableArray<NSMutableDictionary *> *regions;

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        _regions = [NSMutableArray array];
    }
    return self;
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    CGFloat imageScale = [_image recommendedLayerContentsScale:0.0];
    NSSize imageSize = _image.size;

    imageSize.width *= imageScale;
    imageSize.height *= imageScale;

    RECanvasView *canvasView = [[RECanvasView alloc] initWithFrame:NSMakeRect(0, 0, imageSize.width, imageSize.height)];
    canvasView.image = _image;
    canvasView.autoresizingMask = NSViewNotSizable;

    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, imageSize.width, imageSize.height)];
    scrollView.documentView = canvasView;
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = YES;
    scrollView.verticalScrollElasticity = NSScrollElasticityNone;
    scrollView.horizontalScrollElasticity = NSScrollElasticityNone;
    scrollView.borderType = NSNoBorder;
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    NSWindowStyleMask windowStyle =
        NSWindowStyleMaskTitled |
        NSWindowStyleMaskClosable |
        NSWindowStyleMaskResizable |
        NSWindowStyleMaskMiniaturizable;

    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:windowStyle backing:NSBackingStoreBuffered defer:YES];
    window.contentView = scrollView;
    window.contentSize = imageSize;
    window.contentMaxSize = imageSize;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSScreen *screen = NSScreen.mainScreen;

        NSSize screenSize = screen.visibleFrame.size;

        topLeft.x = 10;
        topLeft.y = screenSize.height - 10.0;
    });

    topLeft = [window cascadeTopLeftFromPoint:topLeft];

    NSWindowController *windowController = [[NSWindowController alloc] initWithWindow:window];

    [self addWindowController:windowController];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)error {
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:error];
    if (!imageData) return NO;

    _image = [[NSImage alloc] initWithData:imageData];
    if (!_image) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:@{NSURLErrorKey:url}];
        return NO;
    }

    const char *path = url.fileSystemRepresentation;

    ssize_t size = getxattr(path, REGION_XATTR_NAME, NULL, 0, 0, 0);
    if (size >= 0) {
        NSMutableData *data = [NSMutableData dataWithLength:size];

        size = getxattr(path, REGION_XATTR_NAME, data.mutableBytes, data.length, 0, 0);
        if (size < 0) {
            if (error) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSURLErrorKey:url}];
            return NO;
        }

        id propertyList = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:error];
        if (!propertyList) return NO;

        @try {
            NSInteger index = 0;

            for (NSArray<NSNumber *> *region in propertyList) {
                CGFloat x = region[0].doubleValue;
                CGFloat y = region[1].doubleValue;
                CGFloat w = region[2].doubleValue;
                CGFloat h = region[3].doubleValue;

                NSMutableDictionary<NSString *, NSNumber *> *region = [NSMutableDictionary dictionaryWithRect:NSMakeRect(x, y, w, h)];
                region[@"index"] = @(index++);

                [_regions addObject:region];
            }
        } @catch (NSException *exception) {
            if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:exception.userInfo];
        }
    }
    else if (errno != ENOATTR) {
        if (error) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSURLErrorKey:url}];
        return NO;
    }

    return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(nullable NSURL *)originalContentsURL error:(NSError **)error {
    if (originalContentsURL) {
        if (![[NSFileManager defaultManager] copyItemAtURL:originalContentsURL toURL:url error:error]) return NO;
    }

    NSMutableArray<NSArray<NSNumber *> *> *propertyList = [NSMutableArray arrayWithCapacity:_regions.count];

    for (NSDictionary *region in _regions) {
        NSRect rect = region.rectValue;
        [propertyList addObject:@[@(NSMinX(rect)), @(NSMinY(rect)), @(NSWidth(rect)), @(NSHeight(rect))]];
    }

    NSData *data = [NSPropertyListSerialization dataWithPropertyList:propertyList format:NSPropertyListBinaryFormat_v1_0 options:0 error:error];
    if (!data) return NO;

    const char *path = url.fileSystemRepresentation;

    if (setxattr(path, REGION_XATTR_NAME, data.bytes, data.length, 0, 0) < 0) {
        if (error) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSURLErrorKey:url}];
        return NO;
    }

    return YES;
}

@end

NS_ASSUME_NONNULL_END
