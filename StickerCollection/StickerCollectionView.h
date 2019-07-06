//
//  StickerCollectionView.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/17/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerCollectionDataSource.h"
#import "StickerCollectionFactory.h"
#import "StickerCollectionLayout.h"

typedef NS_ENUM(NSUInteger, StickerCollectionState) {
    StickerCollectionMessaging,
    StickerCollectionEditing,
};

@interface StickerCollectionView : UIScrollView

@property (nonatomic) StickerCollectionState state;
@property (nonatomic) CGFloat autoScrollSpeed;
@property (nonatomic) IBOutlet id<StickerCollectionDataSource> dataSource;
@property (nonatomic) IBOutlet id<StickerCollectionFactory> factory;
@property (nonatomic) IBOutlet id<StickerCollectionLayout> layout;

@end
