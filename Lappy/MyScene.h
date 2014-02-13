//  MyScene.h
//  Lappy
//  Copyright (c) 2014 Sanjay Sheombar. All rights reserved.

#import <SpriteKit/SpriteKit.h>
#import "Obstacle.h"

@interface MyScene : SKScene <SKPhysicsContactDelegate>

@property SKSpriteNode *bird;

@property SKSpriteNode *pipeOneBottom;
@property SKSpriteNode *pipeOneTop;
@property SKSpriteNode *pipeTwoBottom;
@property SKSpriteNode *pipeTwoTop;

@end