//
//  NSUserDefaults+StickerCollectionDataSource.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/19/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "NSMutableArray+Ex.h"
#import "NSUserDefaults+StickerCollectionDataSource.h"

NSString * const kUserDefaultsStickerNameKey = @"kUserDefaultsStickerNameKey";
NSString * const kUserDefaultsStickerExtensionKey = @"kUserDefaultsStickerExtensionKey";
NSString * const kUserDefaultsStickerLocalizedDescriptionKey = @"kUserDefaultsStickerLocalizedDescriptionKey";

@interface NSMutableArray(StickerCollectionUserDefaultsComposer) <StickerCollectionUserDefaultsComposer>

@end

@interface StickerCollectionDataSourceImplementation : NSObject <StickerCollectionDataSource> {
    
    NSUserDefaults *_userDefaults;
    
    NSString *_key;
    NSMutableArray<NSDictionary *> *_source;
    NSMutableArray<MSSticker *> *_stickers;
    
}

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                                 key:(NSString *)key
                              source:(NSMutableArray<NSDictionary *> *)source
                            stickers:(NSMutableArray<MSSticker *> *)stickers  NS_DESIGNATED_INITIALIZER;

@end

@implementation NSUserDefaults(StickerCollectionDataSource)

- (id<StickerCollectionDataSource>)stickerCollectionDataSource:(StickerCollectionUserDefaultsCompositionBlock)compositionBlock {
    return [self stickerCollectionDataSource:@"StickerCollectionDataSource"
                               usingComposer:compositionBlock];
}

- (id<StickerCollectionDataSource>)stickerCollectionDataSource:(NSString *)key
                                                 usingComposer:(StickerCollectionUserDefaultsCompositionBlock)compositionBlock
{
    return [self stickerCollectionDataSource:NSBundle.mainBundle
                                     withKey:key
                               usingComposer:compositionBlock];
}

- (id<StickerCollectionDataSource>)stickerCollectionDataSource:(NSBundle *)bundle
                                                       withKey:(NSString *)key
                                                 usingComposer:(StickerCollectionUserDefaultsCompositionBlock)compositionBlock
{
    NSArray<NSDictionary *> *source = [self objectForKey:key] ?: ({
        NSMutableArray *composer = [[NSMutableArray alloc] init];
        compositionBlock(composer);
        [self setObject:composer forKey:key];
        [composer copy];
    });
    return [[StickerCollectionDataSourceImplementation alloc] initWithUserDefaults:self key:key source:[source mutableCopy] stickers:({
        NSMutableArray<MSSticker *> *stickers = [[NSMutableArray alloc] initWithCapacity:source.count];
        for (NSDictionary *dict in source) {
            [stickers addObject:({
                [[MSSticker alloc] initWithContentsOfFileURL:({
                    [bundle URLForResource:dict[kUserDefaultsStickerNameKey]
                             withExtension:dict[kUserDefaultsStickerExtensionKey]];
                }) localizedDescription:dict[kUserDefaultsStickerLocalizedDescriptionKey] error:nil];
            })];
        }
        stickers;
    })];
}

@end

@implementation NSMutableArray(StickerCollectionUserDefaultsComposer)

- (void)addSticker:(NSString *)name extension:(NSString *)extension {
    [self addSticker:name extension:extension localizedDescription:name];
}

- (void)addSticker:(NSString *)name extension:(NSString *)extension localizedDescription:(NSString *)localizedDescription {
    [self addObject:({
        @{kUserDefaultsStickerNameKey: name,
          kUserDefaultsStickerExtensionKey: extension,
          kUserDefaultsStickerLocalizedDescriptionKey: localizedDescription};
    })];
}

@end

@implementation StickerCollectionDataSourceImplementation

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                                 key:(NSString *)key
                              source:(NSMutableArray<NSDictionary *> *)source
                            stickers:(NSMutableArray<MSSticker *> *)stickers
{
    NSParameterAssert(userDefaults);
    NSParameterAssert(key);
    NSParameterAssert(source);
    NSParameterAssert(stickers);
    NSParameterAssert(source.count == stickers.count);
    self = [super init];
    if (self) {
        _userDefaults = userDefaults;
        _key = key;
        _source = source;
        _stickers = stickers;
    }
    return self;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [_stickers countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - StickerCollectionDataSource

- (NSUInteger)stickersCount {
    return _stickers.count;
}

- (MSSticker *)stickerAtIndex:(NSUInteger)index {
    return _stickers[index];
}

- (BOOL)moveStickerFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    [_source stickerCollection_moveObjectFrom:fromIndex to:toIndex];
    [_stickers stickerCollection_moveObjectFrom:fromIndex to:toIndex];
    [_userDefaults setObject:_source forKey:_key];
    return YES;
}

@end
