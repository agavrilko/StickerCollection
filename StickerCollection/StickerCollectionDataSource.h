//
//  StickerCollectionDataSource.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/17/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <Messages/Messages.h>

@protocol StickerCollectionDataSource <NSFastEnumeration>

@property (readonly, nonatomic) NSUInteger stickersCount;

- (MSSticker *)stickerAtIndex:(NSUInteger)index;
- (BOOL)moveStickerFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex;

@end
