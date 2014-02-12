//  MyScene.m
//  Lappy
//  Created by Sanjay on 11/2/14.
//  Copyright (c) 2014 Sanjay Sheombar. All rights reserved.

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
	if (self = [super initWithSize:size]) {
			/* Setup your scene here */

		self.backgroundColor = [SKColor colorWithRed:255 green:255 blue:255 alpha:1.0];
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		_screenWidth = screenRect.size.width;
		_screenHeight = screenRect.size.height;

		// World Gravity
		[self.physicsWorld setGravity:CGVectorMake(0.0, -3.0)];

		// Create bird
		_bird = [SKSpriteNode spriteNodeWithImageNamed:@"flappy"];

		// Adding physics body
		_bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.frame.size.width];
		_bird.physicsBody.affectedByGravity = YES;
		_bird.physicsBody.dynamic = YES;

		// Scaling the bird down + Default position
		_bird.xScale = 0.20;
		_bird.yScale = 0.20;
		_bird.position = CGPointMake((_screenWidth / 2) - 65, _screenHeight / 2);
		[self addChild:_bird];
	}
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	/* Called when a touch begins */

	for (UITouch *touch in touches) {
		[_bird.physicsBody applyImpulse:CGVectorMake(0, 1000)];
//		CGPoint location = [touch locationInNode:self];
//		SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//		sprite.position = location;
//		SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//		[sprite runAction:[SKAction repeatActionForever:action]];
//		[self addChild:sprite];
	}
}

-(void)update:(CFTimeInterval)currentTime {
	/* Called before each frame is rendered */
	
	// If bird hits bottom..
	if(_bird.position.y <= _bird.size.height) {
		_bird.physicsBody.affectedByGravity = NO;
		_bird.physicsBody.dynamic = NO;
	}
	
}

@end