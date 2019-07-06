//
//  NSMutableArray+StickerCollectionDataSource.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/17/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "NSMutableArray+Ex.h"
#import "NSMutableArray+StickerCollectionDataSource.h"

@implementation NSMutableArray(StickerCollectionDataSource)

- (NSUInteger)stickersCount {
    return self.count;
}

- (MSSticker *)stickerAtIndex:(NSUInteger)index {
    return [self objectAtIndex:index];
}

- (BOOL)moveStickerFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    return [self stickerCollection_moveObjectFrom:fromIndex to:toIndex];
}

@end
