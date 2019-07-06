//
//  StickerCollectionFactory.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 6/8/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <Messages/Messages.h>

@class StickerView;

@protocol StickerCollectionFactory

- (StickerView *)stickerView:(CGRect)frame sticker:(MSSticker *)sticker;

@end
