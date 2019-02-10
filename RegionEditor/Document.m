//
//  Document.m
//  RegionEditor
//
//  Created by Rob Menke on 1/19/19.
//  Copyright © 2019 Rob Menke. All rights reserved.
//

#import "Document.h"
#import "RECanvasView.h"

@import Darwin.POSIX.sys.xattr;

NS_ASSUME_NONNULL_BEGIN

const char *const REGION_XATTR_NAME = "com.the-wabe.regions";

static NSPoint topLeft;

@interface Document ()

@property (nonatomic, nullable, readonly) NSData *data;
@property (nonatomic, nullable, readonly) NSImage *image;
@property (nonatomic, nonnull) NSMutableArray<NSValue *> *regions;
@property (nonatomic, nonnull) NSArrayController *arrayController;

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        _regions = [NSMutableArray array];
        _arrayController = [[NSArrayController alloc] init];
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

    [_arrayController bind:NSContentArrayBinding toObject:self withKeyPath:@"regions" options:@{NSRaisesForNotApplicableKeysBindingOption:@YES}];
    [_arrayController bind:NSSelectionIndexesBinding toObject:canvasView withKeyPath:@"selectionIndexes" options:@{NSRaisesForNotApplicableKeysBindingOption:@YES}];
    [canvasView bind:@"regions" toObject:_arrayController withKeyPath:@"arrangedObjects" options:nil];

    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, imageSize.width, imageSize.height)];
    scrollView.documentView = canvasView;
    scrollView.hasVerticalScroller = YES;
    scrollView.hasHorizontalScroller = YES;
    scrollView.verticalScrollElasticity = NSScrollElasticityNone;
    scrollView.horizontalScrollElasticity = NSScrollElasticityNone;
    scrollView.borderType = NSNoBorder;
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.translatesAutoresizingMaskIntoConstraints = YES;

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
        NSSize screenSize = NSScreen.mainScreen.visibleFrame.size;

        topLeft.x = 10;
        topLeft.y = screenSize.height - 10.0;
    });

    topLeft = [window cascadeTopLeftFromPoint:topLeft];

    NSWindowController *windowController = [[NSWindowController alloc] initWithWindow:window];

    [self addWindowController:windowController];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)error {
    _data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:error];
    if (!_data) return NO;

    _image = _data ? [[NSImage alloc] initWithData:_data] : nil;

    if (!self.image) {
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
            for (NSArray<NSNumber *> *region in propertyList) {
                CGFloat x = region[0].doubleValue;
                CGFloat y = region[1].doubleValue;
                CGFloat w = region[2].doubleValue;
                CGFloat h = region[3].doubleValue;

                [_regions addObject:[NSValue valueWithRect:NSMakeRect(x, y, w, h)]];
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

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)error {
    if (![self.data writeToURL:url options:NSDataWritingAtomic error:error]) return NO;

    NSMutableArray<NSArray<NSNumber *> *> *propertyList = [NSMutableArray arrayWithCapacity:_regions.count];

    for (NSValue *region in _regions) {
        NSRect rect = region.rectValue;
        [propertyList addObject:@[@(NSMinX(rect)), @(NSMinY(rect)), @(NSWidth(rect)), @(NSHeight(rect))]];
    }

    if (propertyList.count) {
        NSData *data = [NSPropertyListSerialization dataWithPropertyList:propertyList format:NSPropertyListBinaryFormat_v1_0 options:0 error:error];
        if (!data) return NO;

        if (setxattr(url.fileSystemRepresentation, REGION_XATTR_NAME, data.bytes, data.length, 0, 0) < 0) {
            if (error) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSURLErrorKey:url}];
            return NO;
        }
    }
    else {
        if (removexattr(url.fileSystemRepresentation, REGION_XATTR_NAME, 0) < 0 && errno != ENOATTR) {
            if (error) *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSURLErrorKey:url}];
            return NO;
        }
    }

    return YES;
}

- (void)resizeRegionAtIndex:(NSUInteger)index toValue:(NSValue *)newValue {
    id oldValue = [self.arrayController valueAtIndex:index inPropertyWithKey:@"arrangedObjects"];

    [[self.undoManager prepareWithInvocationTarget:self] resizeRegionAtIndex:index toValue:oldValue];
    self.undoManager.actionName = @"Resize Region";

    [self.arrayController removeObjectAtArrangedObjectIndex:index];
    [self.arrayController insertObject:newValue atArrangedObjectIndex:index];
}

- (void)insertRegion:(NSValue *)region atIndex:(NSUInteger)index {
    [[self.undoManager prepareWithInvocationTarget:self] deleteRegionAtIndex:index];
    if (!self.undoManager.isUndoing) self.undoManager.actionName = @"Insert Region";

    [self.arrayController insertObject:region atArrangedObjectIndex:index];
}

- (void)deleteRegionAtIndex:(NSUInteger)index {
    id oldValue = [self.arrayController valueAtIndex:index inPropertyWithKey:@"arrangedObjects"];

    [[self.undoManager prepareWithInvocationTarget:self] insertRegion:oldValue atIndex:index];
    if (!self.undoManager.isUndoing) self.undoManager.actionName = @"Delete Region";

    [self.arrayController removeObjectAtArrangedObjectIndex:index];
}

- (void)raiseRegionAtIndex:(NSUInteger)index {
    id oldValue = [self.arrayController valueAtIndex:index inPropertyWithKey:@"arrangedObjects"];

    [[self.undoManager prepareWithInvocationTarget:self] lowerRegionAtIndex:(index - 1)];
    if (!self.undoManager.isUndoing) self.undoManager.actionName = @"Raise Region";

    [self.arrayController removeObjectAtArrangedObjectIndex:index];
    [self.arrayController insertObject:oldValue atArrangedObjectIndex:(index - 1)];
}

- (void)lowerRegionAtIndex:(NSUInteger)index {
    id oldValue = [self.arrayController valueAtIndex:index inPropertyWithKey:@"arrangedObjects"];

    [[self.undoManager prepareWithInvocationTarget:self] raiseRegionAtIndex:(index + 1)];
    if (!self.undoManager.isUndoing) self.undoManager.actionName = @"Lower Region";

    [self.arrayController removeObjectAtArrangedObjectIndex:index];
    [self.arrayController insertObject:oldValue atArrangedObjectIndex:(index + 1)];
}

#pragma mark - Actions

- (IBAction)resize:(id)sender {
    [self resizeRegionAtIndex:_arrayController.selectionIndex toValue:[sender valueForKey:@"frame"]];
}

- (IBAction)add:(id)sender {
    [self insertRegion:[sender valueForKey:@"rectValue"] atIndex:[_arrayController.arrangedObjects count]];
}

- (IBAction)delete:(id)sender {
    [self deleteRegionAtIndex:_arrayController.selectionIndex];
}

- (IBAction)raise:(id)sender {
    [self raiseRegionAtIndex:_arrayController.selectionIndex];
}

- (IBAction)lower:(id)sender {
    [self lowerRegionAtIndex:_arrayController.selectionIndex];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    if (item.action == @selector(raise:)) {
        return _arrayController.selectionIndex > 0;
    }
    else if (item.action == @selector(lower:)) {
        return _arrayController.selectionIndex < ([_arrayController.arrangedObjects count] - 1);
    }

    return [super validateUserInterfaceItem:item];
}

@end

NS_ASSUME_NONNULL_END
