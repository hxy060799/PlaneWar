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
        self.touchEnabled=YES;
        
        [self initObjects];
        [self getWinsize];
        [self loadSpriteFrames];
        [self loadBackgroundSprites];
        [self startBackgroundMoving];
        [self loadPlayerPlane];
        [self startShootBullet];
        [self startShowEnemies];
        [self startCheckCollision];
    }
    return self;
}

-(void)dealloc{
    [enemies release];
    [bullets release];
    [super dealloc];
}

//资源加载

-(void)loadSpriteFrames{
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"gameArts.plist"];
}

-(void)getWinsize{
    winSize=[[CCDirector sharedDirector]winSize];
}

-(void)initObjects{
    enemies=[[NSMutableArray alloc]init];
    bullets=[[NSMutableArray alloc]init];
}

//背景控制

-(void)loadBackgroundSprites{
    backgroundSprite_1=[CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    backgroundSprite_2=[CCSprite spriteWithSpriteFrameName:@"background_2.png"];
    
    [self getBackgroundHeight];
    
    backgroundSprite_1.anchorPoint=ccp(0.5f,0);
    backgroundSprite_2.anchorPoint=ccp(0.5f,0);
    
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
    id moveEnd=[CCCallFuncND actionWithTarget:self selector:@selector(spriteMoveEndedWithAction:Sprite:) data:backgroundSprite];
    
    [backgroundSprite runAction:[CCSequence actions:moveDown,moveEnd,nil]];
    [backgroundSprite runAction:moveDown];
}

-(void)spriteMoveEndedWithAction:(CCAction*)action Sprite:(CCSprite*)backgroundSprite{
    if(backgroundSprite.position.y==-backgroundHeight){
        backgroundSprite.position=ccp(winSize.width/2,backgroundHeight);
    }
    [self moveBackgroundDownWithSprite:backgroundSprite];
}

//玩家飞机的生成和控制

-(void)loadPlayerPlane{
    playerPlane=[CCSprite spriteWithSpriteFrameName:@"hero_fly_1.png"];
    playerPlane.position=ccp(winSize.width/2,0.2*winSize.height);
    [self addChild:playerPlane z:3];
    
    CCAction *planeAction=[self frameAnimationWithFrameName:@"hero_fly_%i.png" FrameCount:2 Delay:0.2f RepeatTimes:0];
    [playerPlane runAction:planeAction];
    
    //id moveLeft=[CCMoveTo actionWithDuration:3.0 position:ccp(0,0.2*winSize.height)];
    //id moveRight=[CCMoveTo actionWithDuration:3.0 position:ccp(winSize.width,0.2*winSize.height)];
    //id moveSeq=[CCSequence actions:moveLeft,moveRight,nil];
    
    //[playerPlane runAction:[CCRepeatForever actionWithAction:moveSeq]];
}

//敌机生成和控制

-(void)startShowEnemies{
    [self schedule:@selector(showEnemy) interval:0.8f];
}

-(void)stopShowEnemies{
    [self unschedule:@selector(showEnemy)];
}

-(void)showEnemy{
    CCSprite *enemy=[CCSprite spriteWithSpriteFrameName:@"enemy1_fly_1.png"];
    enemy.anchorPoint=ccp(0.5,0);
    enemy.position=ccp(arc4random()%(int)(winSize.width+1),winSize.height);
    [self addChild:enemy z:4];
    
    [enemies addObject:enemy];
    
    id enemyMoveDown=[CCMoveBy actionWithDuration:2.0f position:ccp(0,-winSize.height-enemy.boundingBox.size.height)];
    id enemyMoveEnd=[CCCallFuncND actionWithTarget:self selector:@selector(enemyMoveEndedWithAction:Sprite:) data:enemy];
    
    [enemy runAction:[CCSequence actions:enemyMoveDown,enemyMoveEnd,nil]];
}

-(void)enemyMoveEndedWithAction:(CCAction*)action Sprite:(CCSprite*)enemySprite{
    [enemySprite removeFromParentAndCleanup:YES];
    [enemies removeObject:enemySprite];
}

//子弹生成和控制

-(void)startShootBullet{
    [self schedule:@selector(shootBullet) interval:0.2f];
}

-(void)stopShootBullet{
    [self unschedule:@selector(shootBullet)];
}

-(void)shootBullet{
    CCSprite *bullet=[CCSprite spriteWithSpriteFrameName:@"bullet2.png"];
    bullet.anchorPoint=ccp(0.5,0);
    bullet.position=ccp(playerPlane.position.x,playerPlane.position.y+playerPlane.boundingBox.size.height);
    [self addChild:bullet z:2];
    
    [bullets addObject:bullet];
    
    //加上2px可以防止子弹在移除视图之前消失影响美观.
    id bulletMoveUp=[CCMoveBy actionWithDuration:0.5f position:ccp(0,winSize.height-playerPlane.position.y+2)];
    id bulletMoveEnd=[CCCallFuncND actionWithTarget:self selector:@selector(bulletMoveEndedWithAction:Sprite:) data:bullet];
    
    [bullet runAction:[CCSequence actions:bulletMoveUp,bulletMoveEnd,nil]];
}

-(void)bulletMoveEndedWithAction:(CCAction*)action Sprite:(CCSprite*)bulletSprite{
    [bulletSprite removeFromParentAndCleanup:YES];
    [bullets removeObject:bulletSprite];
}

//碰撞检测

-(void)startCheckCollision{
    [self schedule:@selector(checkingCollision)];
}

-(void)stopCheckCollision{
    [self unschedule:@selector(checkingCollision)];
}

-(void)checkingCollision{
    
    NSMutableArray *readyToRemoveEnemies=[NSMutableArray array];
    
    for(int i=0;i<enemies.count;i++){
        for(CCSprite *bullet in bullets){
            CCSprite *enemy=[enemies objectAtIndex:i];
            if(CGRectIntersectsRect(enemy.boundingBox, bullet.boundingBox)){
                if(enemy.boundingBox.origin.y+enemy.boundingBox.size.height<winSize.height){
                    [readyToRemoveEnemies addObject:enemy];
                }
            }
        }
    }
    
    for(CCSprite *enemy in readyToRemoveEnemies){
        [enemies removeObject:enemy];
        id blowUpAction=[self frameAnimationWithFrameName:@"enemy1_blowup_%i.png" FrameCount:4 Delay:0.1f RepeatTimes:1];
        id enemyBlowUpEnd=[CCCallFuncND actionWithTarget:self selector:@selector(enemyBlowUpEndedWithAction:Sprite:) data:enemy];
        [enemy stopAllActions];
        [enemy runAction:[CCSequence actions:blowUpAction,enemyBlowUpEnd,nil]];
    }
}

-(void)enemyBlowUpEndedWithAction:(CCAction*)action Sprite:(CCSprite*)enemySprite{
    [enemySprite removeFromParentAndCleanup:YES];
}

//音频管理

//道具生成和控制

//触摸处理


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch=[touches anyObject];
    
    CGPoint touchLocation=[touch locationInView:touch.view];
    
    touchLocation=[[CCDirector sharedDirector]convertToGL:touchLocation];
    
    CGPoint oldTouchLocation=[touch previousLocationInView:touch.view];
    oldTouchLocation=[[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    
    CGPoint translation=ccpSub(touchLocation,oldTouchLocation);
    
    if(CGRectContainsPoint(playerPlane.boundingBox,touchLocation)){
        CGPoint newPos = ccpAdd(playerPlane.position,translation);
        if(CGRectContainsRect(CGRectMake(0,0,winSize.width,winSize.height),[self newRectWithSize:playerPlane.boundingBox.size Point:newPos AnchorPoint:ccp(0.5,0.5)])){
            playerPlane.position = newPos;
        }
    }
}

-(CGRect)newRectWithSize:(CGSize)size Point:(CGPoint)point AnchorPoint:(CGPoint)anchorPoint{
    return CGRectMake(point.x-anchorPoint.x*size.width,point.y-anchorPoint.y*size.width,size.width,size.height);
}


//动画管理

-(CCAction*)frameAnimationWithFrameName:(NSString*)frameName FrameCount:(int)count Delay:(float)delay RepeatTimes:(int)repeat{
    NSMutableArray *animationFrames=[NSMutableArray array];
    for(int i=0;i<count;i++){
        [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:[NSString stringWithFormat:frameName,i+1]]];
    }
    
    CCAnimation *animation=[CCAnimation animationWithSpriteFrames:animationFrames delay:delay];
    
    CCAction *action;
    //Repeat<=0为永久循环
    if(repeat<=0){
        action=[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    }else{
        action=[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:animation] times:repeat];
    }
    
    return action;
}

@end
