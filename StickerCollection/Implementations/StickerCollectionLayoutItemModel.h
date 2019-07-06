//
//  StickerCollectionLayoutItem.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/17/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StickerCollectionLayout.h"

@interface StickerCollectionLayoutItemModel : NSObject <StickerCollectionLayoutItem>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSize:(CGSize)size position:(CGPoint)position NS_DESIGNATED_INITIALIZER;

- (CGFloat)comparableDistanceTo:(CGPoint)point;

@end
