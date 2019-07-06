//
//  StickerCollectionRowLayout.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 6/8/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerCollectionLayoutItemModel.h"
#import "StickerCollectionRowLayout.h"

#define NSStickerSizeAssert(stickerSize) NSParameterAssert(stickerSize.width > 0.0f && stickerSize.height > 0.0f);

@implementation StickerCollectionRowLayout {
    
    NSArray<StickerCollectionLayoutItemModel *> *_items;
    
}

- (instancetype)init {
    return [self initWithStickerSize:(CGSize) {
        .width = 160.0f,
        .height = 160.0f
    }];
}

- (instancetype)initWithStickerSize:(CGSize)stickerSize {
    NSStickerSizeAssert(stickerSize);
    self = [super init];
    if (self) {
        _stickerSize = stickerSize;
        _items = @[];
    }
    return self;
}

#pragma mark - StickerCollectionLayout

@synthesize viewSize = _viewSize;
@synthesize contentSize = _contentSize;
@synthesize elementsCount = _elementsCount;

- (id<StickerCollectionLayoutItem>)itemAtIndex:(NSUInteger)count {
    return count < _items.count ? _items[count] : nil;
}

- (NSUInteger)nearestIndexToLocation:(CGPoint)location {
    NSUInteger result = NSNotFound;
    CGFloat min = CGFLOAT_MAX;
    for (NSUInteger i = 0U; i < _items.count; ++i) {
        const CGFloat dst = [_items[i] comparableDistanceTo:location];
        if (dst < min) {
            result = i;
            min = dst;
        }
    }
    return result;
}

- (void)updateViewSize:(CGSize)viewSize elementsCount:(NSUInteger)elementsCount {
    if (_stickerSize.width <= 0.0f || _stickerSize.height <= 0.0f) {
        [NSException raise:NSInvalidArgumentException format:
         @"%@: sticker size should be greater than zero (current value: %@)",
         [self class],
         NSStringFromCGSize(_stickerSize)];
        return;
    }

    CGSize contentSize = (CGSize) { .width = viewSize.width, .height = 0.0f };
    NSMutableArray<StickerCollectionLayoutItemModel *> *items = [[NSMutableArray alloc] initWithCapacity:elementsCount];
    
    do {
        
        if (viewSize.width <= 0.0f || viewSize.height <= 0.0f) {
            break;
        }
        
        if (elementsCount == 0U) {
            break;
        }
        
        const NSUInteger columnsCount = floor(viewSize.width / _stickerSize.width);
        const CGFloat columnXSpace = viewSize.width / columnsCount;
        
        contentSize.height = ceilf((CGFloat)elementsCount / columnsCount) * _stickerSize.height;
        
        for (NSUInteger i = 0, row = 0U, column = 0U; i < elementsCount; ++i) {
            
            [items addObject:({
                [[StickerCollectionLayoutItemModel alloc] initWithSize:_stickerSize position:(CGPoint) {
                    .x = (column + 0.5f) * columnXSpace,
                    .y = (row + 0.5f) * _stickerSize.height,
                }];
            })];
            
            if (++column >= columnsCount) {
                column = 0U;
                ++row;
            }
        }
        
    } while (0);
    
    _viewSize = viewSize;
    _contentSize = contentSize;
    _elementsCount = elementsCount;
    _items = [items copy];
}

#pragma mark - Accessors

- (void)setStickerSize:(CGSize)stickerSize {
    NSStickerSizeAssert(stickerSize);
    if (CGSizeEqualToSize(stickerSize, _stickerSize)) {
        return;
    }
    _stickerSize = stickerSize;
    [self updateViewSize:_viewSize elementsCount:_elementsCount];
}

@end
