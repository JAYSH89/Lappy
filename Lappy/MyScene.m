//  MyScene.m
//  Lappy
//  Created by Sanjay on 11/2/14.
//  Copyright (c) 2014 Sanjay Sheombar. All rights reserved.

#import "MyScene.h"
#import "FMMParallaxNode.h"
@import AVFoundation;

@implementation MyScene {
//	NSTimeInterval sinceTouch;
	AVAudioPlayer* jumpSound;

	FMMParallaxNode *background;
	FMMParallaxNode *ground;

	BOOL gameStarted;
	BOOL GameOver;
}

-(id)initWithSize:(CGSize)size {    
	if (self = [super initWithSize:size]) {
		/* Setup your scene here */
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		_screenWidth = screenRect.size.width;
		_screenHeight = screenRect.size.height;

		// GameOver is false
		gameStarted = YES;
		GameOver = NO;

		// Adding background
		NSArray *backgroudNames = @[@"flappybg.jpg", @"flappybg.jpg"];
		CGSize backgroundSize = CGSizeMake(_screenWidth, _screenHeight);
		background = [[FMMParallaxNode alloc] initWithBackgrounds:backgroudNames
																												 size:backgroundSize
																				 pointsPerSecondSpeed:20.0];
		background.position = CGPointMake(0, 0);
		[self addChild:background];

		// Ground
		NSArray *groundNames = @[@"ground.png", @"ground.png"];
		CGSize groundSize = CGSizeMake(_screenWidth, _screenHeight / 5);
		ground = [[FMMParallaxNode alloc] initWithBackgrounds:groundNames
																												 size:groundSize
																				 pointsPerSecondSpeed:80.0];
		ground.position = CGPointMake(0, 0);
		[self addChild:ground];

		// World Gravity
		[self.physicsWorld setGravity:CGVectorMake(0.0, -4.0)];

		// Create bird
		_bird = [SKSpriteNode spriteNodeWithImageNamed:@"bird1"];

		// Adding physics body
		_bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.frame.size.width];
		_bird.physicsBody.affectedByGravity = YES;
		_bird.physicsBody.dynamic = YES;

		// Default position
		_bird.position = CGPointMake((_screenWidth / 2) - 85, _screenHeight / 2);

		// Adding bird to the layer
		[self addChild:_bird];

		// Sound
		NSError *error;
		NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"jump" withExtension:@"wav"];
		jumpSound = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
		[jumpSound prepareToPlay];
	}
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	/* Called when a touch begins */
	if(!GameOver) {
		for (UITouch *touch in touches) {
			// Moving bird upwards when you tap screen
			[_bird.physicsBody applyImpulse:CGVectorMake(0, 10000.f)];
			[_bird setTexture:[SKTexture textureWithImageNamed:@"bird2"]];

			[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(openWings) userInfo:nil repeats:NO];
			[jumpSound play];
		}
	}
}

-(void)update:(CFTimeInterval)currentTime {
	/* Called before each frame is rendered */

	// Updating background scrolling
	if(!GameOver) {
		[background update:currentTime];
		[ground update:currentTime];
	}

	// Maximize upwards speed
	float yVelocity = CLAMP(_bird.physicsBody.velocity.dy, -1 * MAXFLOAT, 250.f);
	_bird.physicsBody.velocity = CGVectorMake(0, yVelocity);

	// If bird hits bottom..
	if(_bird.position.y <= (_screenHeight / 4) - 10) {
		_bird.physicsBody.affectedByGravity = NO;
		_bird.physicsBody.dynamic = NO;
		GameOver = YES;
	}
}

- (void)openWings {
	[_bird setTexture:[SKTexture textureWithImageNamed:@"bird1"]];
}

@end