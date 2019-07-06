//
//  StickerCollectionLayout.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 6/8/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

@protocol StickerCollectionLayoutItem

@property (readonly, nonatomic) CGSize size;
@property (readonly, nonatomic) CGPoint position;

@end

@protocol StickerCollectionLayout

@property (readonly, nonatomic) CGSize viewSize;
@property (readonly, nonatomic) CGSize contentSize;
@property (readonly, nonatomic) NSUInteger elementsCount;

- (id<StickerCollectionLayoutItem>)itemAtIndex:(NSUInteger)count;
- (NSUInteger)nearestIndexToLocation:(CGPoint)location;

- (void)updateViewSize:(CGSize)viewSize elementsCount:(NSUInteger)elementsCount;

@end
