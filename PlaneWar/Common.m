//
//  Common.m
//  PlaneWar
//
//  Created by jy on 13-8-19.
//  Copyright (c) 2013年 GetToSet. All rights reserved.
//
#import "Common.h"

#define ARC4RANDOM_MAX 0x100000000

CGFloat randomFloatRange(CGFloat begin, CGFloat end){
    CGFloat range = end - begin;
    return ((CGFloat)arc4random() / ARC4RANDOM_MAX) * range + begin;
}

NSInteger randomIntRange(NSInteger begin, NSInteger end){
    return arc4random()%(end-begin+1)+begin;
}
