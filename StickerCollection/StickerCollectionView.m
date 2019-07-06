//
//  StickerCollectionView.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 3/17/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "Defines.h"
#import "NSMutableArray+Ex.h"
#import "StickerView.h"
#import "StickerCollectionRowLayout.h"
#import "StickerCollectionDefaultFactory.h"
#import "StickerCollectionView.h"

#define ANIMATE_VIEW(animation) [UIView animateWithDuration:0.3 animations:^{ animation; }];

typedef NS_ENUM(NSUInteger, OrderingState) {
    OrderingDisabled,
    OrderingReady,
    OrderingInProgress,
};

typedef NS_ENUM(NSUInteger, AutoScrollState) {
    AutoScrollDisabled,
    AutoScrollTop,
    AutoScrollBottom,
};

static CGPoint getPoint(id<StickerCollectionLayoutItem>);
static CGSize getSize(id<StickerCollectionLayoutItem>);
static CGRect getRect(id<StickerCollectionLayoutItem>);
static NSArray *arrayByMoving(NSArray *, NSUInteger, NSUInteger);

@interface StickerView (StickerCollectionView)

- (void)updateIsAnimating:(BOOL)isAnimationg;

@end

@interface StickerCollectionView() {
    
    OrderingState _orderingState;
    AutoScrollState _autoScrollState;
    
    NSArray<StickerView *> *_origin;
    NSArray<StickerView *> *_stickers;
    
    UILongPressGestureRecognizer *_gestureRecognizer;
    CADisplayLink *_displayLink;
    
    NSUInteger _sourceIndex;
    NSUInteger _targetIndex;
}

@end

inline CGPoint getPoint(id<StickerCollectionLayoutItem> item) {
    return item ? item.position : CGPointZero;
}

inline CGSize getSize(id<StickerCollectionLayoutItem> item) {
    return item ? item.size : CGSizeZero;
}

inline CGRect getRect(id<StickerCollectionLayoutItem> item) {
    return item ? (CGRect) {
        .origin = (CGPoint) {
            .x = item.position.x - item.size.width * 0.5f,
            .y = item.position.y - item.size.height * 0.5f,
        },
        .size = item.size,
    } : CGRectZero;
}

inline NSArray *arrayByMoving(NSArray *array, NSUInteger from, NSUInteger to) {
    NSMutableArray *tmp = [array mutableCopy];
    [tmp stickerCollection_moveObjectFrom:from to:to];
    return [tmp copy];
}

@implementation StickerView (StickerCollectionView)

- (void)updateIsAnimating:(BOOL)isAnimationg {
    if (isAnimationg == self.isAnimating) {
        return;
    }
    if (isAnimationg) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

@end

@implementation StickerCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    return [[super initWithFrame:frame] setup];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [[super initWithCoder:aDecoder] setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
    [self updateElementsLayout];
    [self updateStickersAnimation];
}

#pragma mark - Accessors

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    [self updateStickersAnimation];
}

- (void)setState:(StickerCollectionState)state {
    if (state == _state) {
        return;
    }
    UPDATE_KVO_PROPERTY({
        _state = state;
        [self updateOrderingState];
    });
}

- (void)setDataSource:(id<StickerCollectionDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    UPDATE_KVO_PROPERTY({
        
        _dataSource = dataSource;
        [self updateLayout];
        
        const NSUInteger count = _dataSource.stickersCount;
        NSMutableArray *stickers = [[NSMutableArray alloc] initWithCapacity:count];
        for (NSUInteger i = 0; i < count; ++i) {
            StickerView *view = [_factory stickerView:getRect([_layout itemAtIndex:i])
                                              sticker:[_dataSource stickerAtIndex:i]];
            [stickers addObject:view];
            [self addSubview:view];
        }
        
        _origin = [stickers copy];
        _stickers = [stickers copy];
        
        [self updateOrderingState];
        [self updateStickersAnimation];
        
    });
}

#pragma mark - Private

- (instancetype)setup {
    
    _autoScrollSpeed = 312.0f;
    
    _factory = [[StickerCollectionDefaultFactory alloc] init];
    _layout = [[StickerCollectionRowLayout alloc] init];
                
    _sourceIndex = NSNotFound;
    _targetIndex = NSNotFound;
                
    return self;
}

- (void)updateOrderingState {
    [self updateOrderingState:^OrderingState {
        switch (_state) {
            case StickerCollectionMessaging: return OrderingDisabled;
            case StickerCollectionEditing: return OrderingReady;
        }
    } ()];
}

- (void)updateOrderingState:(OrderingState)interactionState {
    if (_orderingState == interactionState) {
        return;
    }
    
    switch (interactionState) {
            
        case OrderingDisabled:
            NSParameterAssert(_sourceIndex == NSNotFound);
            NSParameterAssert(_targetIndex == NSNotFound);
            if (_gestureRecognizer) {
                [self removeGestureRecognizer:_gestureRecognizer];
            }
            [self updateAutoScrollState:AutoScrollDisabled];
            break;
            
        case OrderingReady:
            NSParameterAssert(_sourceIndex == NSNotFound);
            NSParameterAssert(_targetIndex == NSNotFound);
            if (_gestureRecognizer == nil) {
                _gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
            }
            [self addGestureRecognizer:_gestureRecognizer];
            [self updateAutoScrollState:AutoScrollDisabled];
            break;
            
        case OrderingInProgress:
            NSParameterAssert(_sourceIndex != NSNotFound);
            NSParameterAssert(_targetIndex != NSNotFound);
            break;
            
    }
    
    _orderingState = interactionState;
    [self updateStickersUserInteraction];
    [self updateStickersAnimation];
    [self updateStickerSelection];
}

- (void)updateAutoScrollState:(AutoScrollState)autoScrollState {
    if (_autoScrollState == autoScrollState) {
        return;
    }
    
    switch (autoScrollState) {
            
        case AutoScrollDisabled:
            if (_displayLink) {
                [_displayLink removeFromRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
            }
            break;
            
        default:
            if (_displayLink == nil) {
                _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScrollAction:)];
            }
            [_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
            break;
            
    }
    
    _autoScrollState = autoScrollState;
}

- (void)updateLayout {
    [_layout updateViewSize:self.bounds.size elementsCount:_dataSource.stickersCount];
    self.contentSize = _layout.contentSize;
}

- (void)updateStickersUserInteraction {
    [_stickers enumerateObjectsUsingBlock:^(StickerView *view, NSUInteger index, BOOL *stop) {
        view.userInteractionEnabled = _orderingState == OrderingDisabled;
    }];
}

- (void)updateElementsLayout {
    [_stickers enumerateObjectsUsingBlock:^(StickerView *view, NSUInteger index, BOOL *stop) {
        if (index != _targetIndex) {
            _stickers[index].center = getPoint([_layout itemAtIndex:index]);
        }
    }];
}

- (void)updateStickersAnimation {
    [_stickers enumerateObjectsUsingBlock:^(StickerView *view, NSUInteger index, BOOL *stop) {
        const BOOL isVisible = CGRectIntersectsRect(view.frame, self.bounds);
        view.bouncing = _orderingState == OrderingDisabled ? NO : isVisible;
        [view updateIsAnimating:isVisible];
    }];
}

- (void)updateStickerSelection {
    [_stickers enumerateObjectsUsingBlock:^(StickerView *view, NSUInteger index, BOOL *stop) {
        switch (_orderingState) {
                
            case OrderingInProgress:
                view.selected = index == _sourceIndex;
                break;
                
            default:
                view.selected = NO;
                break;
                
        }
    }];
}

#pragma mark - Private (Actions)

- (void)longPressAction:(UILongPressGestureRecognizer *)sender {
    switch (sender.state) {
            
        case UIGestureRecognizerStateBegan:
            switch (_orderingState) {
                    
                case OrderingReady: {
                    
                    const CGPoint location = [sender locationInView:self];
                    _sourceIndex = [self.layout nearestIndexToLocation:location];
                    
                    if (_sourceIndex == NSNotFound) {
                        break;
                    }

                    _targetIndex = _sourceIndex;
                    [self updateOrderingState:OrderingInProgress];
                    break;
                }
                    
                default:
                    break;
                    
            }
            break;
            
        case UIGestureRecognizerStateChanged:
            switch (_orderingState) {
                    
                case OrderingInProgress: {
                    
                    const CGPoint location = [sender locationInView:self];
                    
                    NSUInteger targetIndex = [self.layout nearestIndexToLocation:location];
                    if (targetIndex == NSNotFound) {
                        targetIndex = _sourceIndex;
                    }
                    
                    if (targetIndex != _targetIndex) {
                        _targetIndex = targetIndex;
                        _stickers = ({
                            _sourceIndex == _targetIndex ?
                            [_origin copy] :
                            arrayByMoving(_origin, _sourceIndex, _targetIndex);
                        });
                        ANIMATE_VIEW([self updateElementsLayout]);
                    }
                    
                    _stickers[_targetIndex].center = location;
                    
                    [self updateAutoScrollState:^AutoScrollState {
                        const CGSize itemSize = getSize([_layout itemAtIndex:_targetIndex]);
                        const CGFloat halfHeight = itemSize.height * 0.5f;
                        if (location.y - halfHeight < self.contentOffset.y) {
                            return AutoScrollBottom;
                        }
                        if (location.y + halfHeight > self.contentOffset.y + self.visibleSize.height) {
                            return AutoScrollTop;
                        }
                        return AutoScrollDisabled;
                    } ()];
                    
                    break;
                }
                    
                default:
                    break;
                    
            }
            
            break;
            
        case UIGestureRecognizerStateEnded:
            switch (_orderingState) {
                    
                case OrderingInProgress: {

                    if ([_dataSource moveStickerFrom:_sourceIndex to:_targetIndex]) {
                        _origin = [_stickers copy];
                    } else {
                        _stickers = [_origin copy];
                    }
                    
                    _sourceIndex = NSNotFound;
                    _targetIndex = NSNotFound;
                    
                    ANIMATE_VIEW([self updateElementsLayout]);
                    [self updateOrderingState:OrderingReady];
                    break;
                }
                    
                default:
                    break;
                    
            }
            break;
            
        case UIGestureRecognizerStateCancelled:
            switch (_orderingState) {
                    
                case OrderingInProgress: {
                    
                    _sourceIndex = NSNotFound;
                    _targetIndex = NSNotFound;
                    
                    [self updateElementsLayout];
                    [self updateOrderingState:OrderingReady];
                    break;
                }
                    
                default:
                    break;
                    
            }
            break;
            
        default:
            break;
            
    }
}

- (void)autoScrollAction:(CADisplayLink *)displayLink {
    switch (_autoScrollState) {
            
        case AutoScrollDisabled:
            return;
            
        case AutoScrollTop: {
            CGFloat y = self.contentOffset.y + _displayLink.duration * _autoScrollSpeed;
            if (y > self.contentSize.height - self.visibleSize.height) {
                y = self.contentSize.height - self.visibleSize.height;
            }
            self.contentOffset = (CGPoint) {
                .x = self.contentOffset.x,
                .y = y,
            };
            break;
        }
            
        case AutoScrollBottom: {
            CGFloat y = self.contentOffset.y - _displayLink.duration * _autoScrollSpeed;
            if (y < 0.0f) {
                y = 0.0f;
            }
            self.contentOffset = (CGPoint) {
                .x = self.contentOffset.x,
                .y = y,
            };
            break;
        }
            
    }
    [self longPressAction:_gestureRecognizer];
}

@end
