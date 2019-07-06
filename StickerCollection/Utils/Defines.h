//
//  Defines.h
//  StickerCollection
//
//  Created by Alexander Gavrilko on 6/9/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UPDATE_KVO_PROPERTY(invocation) ({ \
    [self willChangeValueForKey:NSStringFromSelector(_cmd)]; \
    invocation; \
    [self didChangeValueForKey:NSStringFromSelector(_cmd)]; \
})
