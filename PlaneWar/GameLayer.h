//
//  GameLayer.h
//  PlaneWar
//
//  Created by Bill on 13-8-16.
//  Copyright (c) 2013年 GetToSet. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer : CCLayer<UIAlertViewDelegate>{
    CCSprite *backgroundSprite_1;
    CCSprite *backgroundSprite_2;
    
    CCSprite *playerPlane;
    
    CCSprite *bomb;
    
    CCLabelTTF *scoreLabel;
    
    CGSize winSize;
    float backgroundHeight;
    
    NSMutableArray *enemies;
    NSMutableArray *bullets;
    NSMutableArray *props;
    
    BOOL superBullet;
    
    int bombCount;
    
    int score;
}

+(CCScene*)scene;

@end
