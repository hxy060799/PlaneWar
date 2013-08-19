//
//  Common.m
//  PlaneWar
//
//  Created by jy on 13-8-19.
//  Copyright (c) 2013年 GetToSet. All rights reserved.
//
#import "Common.h"

#define ARC4RANDOM_MAX 0x100000000

float randomFloatRange(float begin, float end){
    float range = end - begin;
    float result = ((float)arc4random() / ARC4RANDOM_MAX) * range + begin;
    return result;
}

int randomIntRange(int begin, int end){
    return arc4random()%(end-begin+1)+begin;
}
