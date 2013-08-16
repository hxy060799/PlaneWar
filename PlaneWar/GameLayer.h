//
//  GameLayer.h
//  PlaneWar
//
//  Created by Bill on 13-8-16.
//  Copyright (c) 2013年 GetToSet. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer : CCLayer{
    CCSprite *backgroundSprite_1;
    CCSprite *backgroundSprite_2;
    
    CGSize winSize;
    float backgroundHeight;
}

+(CCScene*)scene;

@end
