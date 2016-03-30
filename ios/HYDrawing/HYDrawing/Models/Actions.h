//
//  Actions.h
//  HYDrawing
//
//  Created by CharlyZhang on 16/3/30.
//  Copyright © 2016年 Founder. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ActionType {
    kCanvasChanging,
    kAddingLayer
} ActionType;

@interface Actions : NSObject

@property (nonatomic,readonly) ActionType type;
@property (nonatomic) NSInteger activeLayerIdx;

+ (Actions*) createCanvasChangingAction:(NSInteger) layerIdx;
+ (Actions*) createAddingLayerAction;

@end
