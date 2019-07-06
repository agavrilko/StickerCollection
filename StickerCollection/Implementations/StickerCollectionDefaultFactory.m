//
//  StickerCollectionDefaultFactory.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 6/9/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "StickerView.h"
#import "StickerCollectionDefaultFactory.h"

@implementation StickerCollectionDefaultFactory

#pragma mark - StickerCollectionFactory

- (StickerView *)stickerView:(CGRect)frame sticker:(MSSticker *)sticker {
    return [[StickerView alloc] initWithFrame:frame sticker:sticker];
}

@end
