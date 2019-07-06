//
//  NSMutableArray+Ex.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/17/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "NSMutableArray+Ex.h"

@implementation NSMutableArray(Ex)

- (BOOL)stickerCollection_moveObjectFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    if (fromIndex >= self.count || toIndex >= self.count) {
        return NO;
    }
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
    return YES;
}

@end
