//
//  StickerCollectionLayoutItem.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/17/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "StickerCollectionLayoutItemModel.h"

@interface StickerCollectionLayoutItemModel()

@end

@implementation StickerCollectionLayoutItemModel

- (instancetype)initWithSize:(CGSize)size position:(CGPoint)position {
    self = [super init];
    if (self) {
        _size = size;
        _position = position;
    }
    return self;
}

- (CGFloat)comparableDistanceTo:(CGPoint)point {
    return fabs(_position.x - point.x) + fabs(_position.y - point.y);
}

#pragma mark - StickerCollectionLayoutItem

@synthesize size = _size;
@synthesize position = _position;

@end
