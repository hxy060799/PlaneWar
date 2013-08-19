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
        [self loadBombButton];
        [self startShowProps];
        [self loadScoreLabel];
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
    props=[[NSMutableArray alloc]init];
    
    superBullet=NO;
    bombCount=0;
    score=0;
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

//分数标签

-(void)loadScoreLabel{
    scoreLabel=[CCLabelTTF labelWithString:@"Score:0" fontName:@"MarkerFelt-Thin" fontSize:winSize.height*0.0625];
    [scoreLabel setColor:ccc3(0, 0, 0)];
    scoreLabel.anchorPoint=ccp(0,1);
    scoreLabel.position=ccp(0,winSize.height);
    [self addChild:scoreLabel];
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
    
    int type=arc4random()%20+1;
    int hp=0;
    if(type<=16){
        type=1;
        hp=1;
    }else if(type<=18){
        type=3;
        hp=15;
    }else{
        type=2;
        hp=30;
    }
    
    CCSprite *enemy=[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"enemy%i_fly_1.png",type]];
    enemy.anchorPoint=ccp(0.5,0);
    enemy.position=ccp(20+arc4random()%(int)(winSize.width-40+1),winSize.height);
    [self addChild:enemy z:4];
    
    //Tag用于记录敌机类型和HP值(这比再写一个类要方便多了)
    [enemy setTag:type*100+hp];
    
    [enemies addObject:enemy];
    
    if(type==2){
        id action=[self frameAnimationWithFrameName:@"enemy2_fly_%i.png" FrameCount:2 Delay:0.2 RepeatTimes:0];
        [enemy runAction:action];
    }
    
    id enemyMoveDown=[CCMoveBy actionWithDuration:5.0f position:ccp(0,-winSize.height-enemy.boundingBox.size.height)];
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
    CCSprite *bullet=[CCSprite spriteWithSpriteFrameName:(!superBullet)?@"bullet1.png":@"bullet2.png"];
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
        CCSprite *enemy=[enemies objectAtIndex:i];
        if(CGRectIntersectsRect(enemy.boundingBox, playerPlane.boundingBox)){
            [self stopCheckCollision];
            [self stopShootBullet];
            [self stopBackgroundMoving];
            [self stopShowEnemies];
            [self stopShowProps];
            
            id gameOverAction=[self frameAnimationWithFrameName:@"hero_blowup_%i.png" FrameCount:4 Delay:0.1f RepeatTimes:1];
            id actionEnd=[CCCallFuncND actionWithTarget:self selector:@selector(gameOverBlowUpEndedWithAction:Sprite:) data:playerPlane];
            [playerPlane runAction:[CCSequence actions:gameOverAction,actionEnd,nil]];
        }
        for(CCSprite *bullet in bullets){
            if(CGRectIntersectsRect(enemy.boundingBox, bullet.boundingBox)){
                if(enemy.boundingBox.origin.y+enemy.boundingBox.size.height<winSize.height){
                    if([self getEnemyHpWithTag:enemy.tag]>=2&&superBullet){
                        enemy.tag-=2;
                    }else{
                        enemy.tag--;
                    }
                    int hp=[self getEnemyHpWithTag:enemy.tag];
                    if(hp<=0){
                        [readyToRemoveEnemies addObject:enemy];
                    }else{
                        int type=[self getEnemyTypeWithTag:enemy.tag];
                        if(type==2){
                            [enemy setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"enemy2_hit_1.png"]];
                        }else if(type==3){
                            id hitAction=[self frameAnimationWithFrameName:@"enemy3_hit_%i.png" FrameCount:2 Delay:0.1f RepeatTimes:1];
                            [enemy runAction:hitAction];
                        }
                    }
                }
            }
        }
    }
    
    for(CCSprite *enemy in readyToRemoveEnemies){
        [self blowUpWithEnemy:enemy];
        [enemies removeObject:enemy];
    }
    
    NSMutableArray *readyToRemoveProps=[NSMutableArray array];
    
    for(CCSprite *prop in props){
        if(CGRectIntersectsRect(prop.boundingBox, playerPlane.boundingBox)){
            [readyToRemoveProps addObject:prop];
            if(prop.tag==5){
                if(!superBullet){
                    superBullet=YES;
                    [self schedule:@selector(cancelSuperBullet) interval:30.0f repeat:1 delay:0.0f];
                }
            }else if(prop.tag==4){
                bombCount++;
                bomb.visible=true;
            }
        }
    }
    
    for(CCSprite *prop in readyToRemoveProps){
        [props removeObject:prop];
        [prop removeFromParentAndCleanup:YES];
    }
}

-(void)blowUpWithEnemy:(CCSprite*)enemy{
    
    int type=[self getEnemyTypeWithTag:enemy.tag];
    
    id blowUpAction;
    
    switch(type){
        case 1:
            score+=100;
            blowUpAction=[self frameAnimationWithFrameName:@"enemy1_blowup_%i.png" FrameCount:4 Delay:0.1f RepeatTimes:1];
            break;
        case 2:
            score+=3000;
            blowUpAction=[self frameAnimationWithFrameName:@"enemy2_blowup_%i.png" FrameCount:7 Delay:0.1f RepeatTimes:1];
            break;
        case 3:
            score+=500;
            blowUpAction=[self frameAnimationWithFrameName:@"enemy3_blowup_%i.png" FrameCount:4 Delay:0.1f RepeatTimes:1];
            break;
    }
    
    [scoreLabel setString:[NSString stringWithFormat:@"Score:%i",score]];
    
    id enemyBlowUpEnd=[CCCallFuncND actionWithTarget:self selector:@selector(enemyBlowUpEndedWithAction:Sprite:) data:enemy];
    [enemy stopAllActions];
    [enemy runAction:[CCSequence actions:blowUpAction,enemyBlowUpEnd,nil]];
    
}

-(void)enemyBlowUpEndedWithAction:(CCAction*)action Sprite:(CCSprite*)enemySprite{
    [enemySprite removeFromParentAndCleanup:YES];
}

-(void)gameOverBlowUpEndedWithAction:(CCAction*)action Sprite:(CCSprite*)planeSprite{
    [planeSprite removeFromParentAndCleanup:YES];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Game Over!" message:[NSString stringWithFormat:@"Your score is %i.",score] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

//音频管理

//道具生成和控制

-(void)startShowProps{
    [self schedule:@selector(showProp) interval:20.0f];
}

-(void)stopShowProps{
    [self unschedule:@selector(showProp)];
}

-(void)showProp{
    
    if(arc4random()*2==1){
        return;
    }
    
    int type=arc4random()%2+4;
    
    CCSprite *prop=[CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"enemy%i_fly_1.png",type]];
    prop.anchorPoint=ccp(0.5,0);
    prop.position=ccp(arc4random()%(int)(winSize.width+1),winSize.height);
    [self addChild:prop z:4];
    
    [prop setTag:type];
    [props addObject:prop];
    
    id propMoveDown1=[CCMoveBy actionWithDuration:0.2f position:ccp(0,(int)-(arc4random()%(int)(winSize.height*0.4)))];
    id propMoveUp=[CCMoveTo actionWithDuration:0.5f position:ccp(prop.position.x,winSize.height)];
    id propMoveDown2=[CCMoveBy actionWithDuration:1.0f position:ccp(0,-winSize.height-prop.boundingBox.size.height)];
    id propMoveEnd=[CCCallFuncND actionWithTarget:self selector:@selector(propsMoveEndedWithAction:Sprite:) data:prop];
    
    [prop runAction:[CCSequence actions:propMoveDown1,propMoveUp,propMoveDown2,propMoveEnd,nil]];
}

-(void)propsMoveEndedWithAction:(CCAction*)action Sprite:(CCSprite*)propSprite{
    [propSprite removeFromParentAndCleanup:YES];
    [props removeObject:propSprite];
}

-(void)cancelSuperBullet{
    superBullet=NO;
}

-(void)loadBombButton{
    bomb=[CCSprite spriteWithSpriteFrameName:@"bomb.png"];
    bomb.anchorPoint=ccp(0,0);
    bomb.position=ccp(winSize.width*0.05,winSize.width*0.05);
    [self addChild:bomb];
    [bomb setVisible:NO];
}

//触摸处理

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint touchLocation=[touch locationInView:touch.view];
    touchLocation=[[CCDirector sharedDirector]convertToGL:touchLocation];
    
    if(CGRectContainsPoint(bomb.boundingBox, touchLocation)){
        if(bombCount>0){
            bombCount--;
            if(bombCount==0){
                bomb.visible=false;
            }
            
            for(CCSprite *enemy in enemies){
                [self blowUpWithEnemy:enemy];
            }
            
            [enemies removeAllObjects];
        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
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

//通用函数

-(int)getEnemyTypeWithTag:(NSUInteger)tag{
    return (tag-tag%100)/100;
}

-(int)getEnemyHpWithTag:(NSUInteger)tag{
    return tag%100;
}

//对话框回调

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    exit(0);
}

@end
