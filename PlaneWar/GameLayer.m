//
//  GameLayer.m
//  PlaneWar
//
//  Created by Bill on 13-8-16.
//  Copyright (c) 2013年 GetToSet. All rights reserved.
//

#import "GameLayer.h"

@implementation GameLayer

//基本方法

+(CCScene*)scene{
    CCScene *scene=[CCScene node];
    GameLayer *layer=[GameLayer node];
    [scene addChild:layer];
    
    return scene;
}

-(id)init{
    if(self=[super init]){
        [self getWinsize];
        [self loadSpriteFrames];
        [self loadBackgroundSprites];
        [self startBackgroundMoving];
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
}

//资源加载

-(void)loadSpriteFrames{
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"gameArts.plist"];
}

-(void)getWinsize{
    winSize=[[CCDirector sharedDirector]winSize];
}

//背景控制

-(void)loadBackgroundSprites{
    backgroundSprite_1=[CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    backgroundSprite_2=[CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    
    [self getBackgroundHeight];
    
    backgroundSprite_1.anchorPoint=ccp(0.5,0);
    backgroundSprite_2.anchorPoint=ccp(0.5,0);
    
    backgroundSprite_1.position=ccp(winSize.width/2,0);
    backgroundSprite_2.position=ccp(winSize.width/2,backgroundHeight);
    
    [self addChild:backgroundSprite_1 z:0];
    [self addChild:backgroundSprite_2 z:0];
}

-(void)getBackgroundHeight{
    //减去2px可以让两个背景块有细微重叠,会看到两个背景块中间的细缝.
    backgroundHeight=backgroundSprite_1.boundingBox.size.height-2;
}

-(void)startBackgroundMoving{
    [self moveBackgroundDownWithSprite:backgroundSprite_1];
    [self moveBackgroundDownWithSprite:backgroundSprite_2];
}

-(void)stopBackgroundMoving{
    [backgroundSprite_1 stopAllActions];
    [backgroundSprite_2 stopAllActions];
}

-(void)moveBackgroundDownWithSprite:(CCSprite*)backgroundSprite{
    id moveDown=[CCMoveBy actionWithDuration:5.0f position:ccp(0,-backgroundHeight)];
    id moveEnded=[CCCallFuncND actionWithTarget:self selector:@selector(spriteMoveEndedWithAction:Sprite:) data:backgroundSprite];
    
    [backgroundSprite runAction:[CCSequence actions:moveDown,moveEnded,nil]];
    [backgroundSprite runAction:moveDown];
}

-(void)spriteMoveEndedWithAction:(CCAction*)action Sprite:(CCSprite*)backgroundSprite{
    if(backgroundSprite.position.y==-backgroundHeight){
        backgroundSprite.position=ccp(winSize.width/2,backgroundHeight);
    }
    [self moveBackgroundDownWithSprite:backgroundSprite];
}

//敌机生成和控制

//子弹生成和控制

//碰撞检测

//音频管理

//道具生成和控制

//触摸处理

//动画管理

@end
