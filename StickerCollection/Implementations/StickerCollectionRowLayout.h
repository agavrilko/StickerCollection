//
//  StickerCollectionRowLayout.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 6/8/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "StickerCollectionLayout.h"

@interface StickerCollectionRowLayout : NSObject <StickerCollectionLayout>

@property (nonatomic) CGSize stickerSize;

- (instancetype)initWithStickerSize:(CGSize)stickerSize NS_DESIGNATED_INITIALIZER;

@end
