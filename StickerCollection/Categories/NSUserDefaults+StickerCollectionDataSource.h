//
//  NSUserDefaults+StickerCollectionDataSource.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/19/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StickerCollectionDataSource.h"

@protocol StickerCollectionUserDefaultsComposer;

typedef void(^StickerCollectionUserDefaultsCompositionBlock)(id<StickerCollectionUserDefaultsComposer>);

extern NSString * const kUserDefaultsStickerNameKey;
extern NSString * const kUserDefaultsStickerExtensionKey;
extern NSString * const kUserDefaultsStickerLocalizedDescriptionKey;

@protocol StickerCollectionUserDefaultsComposer

- (void)addSticker:(NSString *)name extension:(NSString *)extension;
- (void)addSticker:(NSString *)name extension:(NSString *)extension localizedDescription:(NSString *)localizedDescription;

@end

@interface NSUserDefaults(StickerCollectionDataSource)

- (id<StickerCollectionDataSource>)stickerCollectionDataSource:(StickerCollectionUserDefaultsCompositionBlock)compositionBlock;
- (id<StickerCollectionDataSource>)stickerCollectionDataSource:(NSString *)key
                                                 usingComposer:(StickerCollectionUserDefaultsCompositionBlock)compositionBlock;
- (id<StickerCollectionDataSource>)stickerCollectionDataSource:(NSBundle *)bundle
                                                       withKey:(NSString *)key
                                                 usingComposer:(StickerCollectionUserDefaultsCompositionBlock)compositionBlock;

@end
