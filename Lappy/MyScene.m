//  MyScene.m
//  Lappy
//  Created by Sanjay on 11/2/14.
//  Copyright (c) 2014 Sanjay Sheombar. All rights reserved.

#import "MyScene.h"
#import "FMMParallaxNode.h"
@import AVFoundation;

@implementation MyScene {
	int score;
	SKLabelNode *scoreLabel;

	CGFloat screenWidth;
	CGFloat screenHeight;
	AVAudioPlayer* jumpSound;
	AVAudioPlayer* pointSound;

	FMMParallaxNode *background;
	FMMParallaxNode *ground;

	NSMutableArray *bottomPipes;
	NSMutableArray *topPipes;

	BOOL gameStarted;
	BOOL GameOver;
	float direction;
}

-(id)initWithSize:(CGSize)size {    
	if (self = [super initWithSize:size]) {

		/* Setup your scene here */
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		screenWidth = screenRect.size.width;
		screenHeight = screenRect.size.height;

		[self startGame];
	}
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	/* Called when a touch begins */

	// Tap to start
	if(gameStarted == NO) {
		_bird.physicsBody.affectedByGravity = YES;
		_bird.physicsBody.dynamic = YES;
		gameStarted = YES;
	}

	if(!GameOver) {
		for (UITouch *touch in touches) {
			// Moving bird upwards when you tap screen
			[_bird.physicsBody applyImpulse:CGVectorMake(0, 10000.f)];
			[_bird setTexture:[SKTexture textureWithImageNamed:@"bird2"]];

			[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(openWings) userInfo:nil repeats:NO];
			if([jumpSound isPlaying]) {
				[jumpSound stop];
			}
			[jumpSound play];
		}
	}
	if(GameOver) {
		[self removeAllActions];
		[self removeAllChildren];
		[self startGame];
	}
}

-(void)update:(CFTimeInterval)currentTime {
	/* Called before each frame is rendered */

	// Gliding of the bird
	if(gameStarted == NO) {
		if(IS_IPHONE_5) {
			if(_bird.position.y < 264|| _bird.position.y >= 304) {
				direction = direction * - 1;
			}
			[_bird setPosition:CGPointMake(_bird.position.x, _bird.position.y + direction)];
		} else {
			if(_bird.position.y < 220 || _bird.position.y >= 260) {
				direction = direction * - 1;
			}
			[_bird setPosition:CGPointMake(_bird.position.x, _bird.position.y + direction)];
		}
	}

	if(!GameOver) {
		[ground update:currentTime];
	}

	// Updating background scrolling
	if(!GameOver && gameStarted) {
		[background update:currentTime];

		// Move the bottomPipes to the left
		for(Obstacle *bottomPipe in bottomPipes) {
			bottomPipe.position = CGPointMake(bottomPipe.position.x - 3, bottomPipe.position.y);
			if(bottomPipe.position.x - bottomPipe.size.width / 2 < screenWidth / 2 && bottomPipe.isActive == YES) {
				bottomPipe.isActive = NO;
				[self generatePipe];
			}
			// Score
			if(_bird.position.x > bottomPipe.position.x && bottomPipe.gavePoint == NO) {
				bottomPipe.gavePoint = YES;
				score++;
				[pointSound play];
				scoreLabel.text = [NSString stringWithFormat:@"%i", score];
			}
			// Remove pipe if it gets off the screen
			if(bottomPipe.position.x + bottomPipe.size.width / 2 < 0) {
				[bottomPipe removeFromParent];
			}
		}

		// Move the topPipes to the left
		for(Obstacle *topPipe in topPipes) {
			topPipe.position = CGPointMake(topPipe.position.x - 3, topPipe.position.y);

			// Remove pipe if it gets off the screen
			if(topPipe.position.x + topPipe.size.width / 2 < 0) {
				[topPipe removeFromParent];
			}
		}

		// If bird hits bottomPipe object
		for(SKSpriteNode *bottomPipe in bottomPipes) {
			if(_bird.position.x + _bird.size.width / 2 > bottomPipe.position.x - bottomPipe.size.width / 2 &&
				 _bird.position.x - _bird.size.width / 2 < bottomPipe.position.x + bottomPipe.size.width / 2 &&
				 _bird.position.y < bottomPipe.position.y + bottomPipe.frame.size.height / 2) {
				[self didCollide];
			}
		}
		
		// If bird hits TopPipe object
		for(SKSpriteNode *pipeTop in topPipes) {
			if(_bird.position.x + _bird.size.width / 2 > pipeTop.position.x - pipeTop.size.width / 2 &&
				 _bird.position.x - _bird.size.width / 2 < pipeTop.position.x + pipeTop.size.width / 2 &&
				 _bird.position.y + _bird.size.height / 2 > pipeTop.position.y - pipeTop.size.height / 2) {
				[self didCollide];
			}
		}
	}

	// If bird hits Ground..
	if(_bird.position.y <= screenHeight / 5 + (_bird.size.height / 2)) {
		_bird.physicsBody.affectedByGravity = NO;
		_bird.physicsBody.dynamic = NO;
		GameOver = YES;
	}

	// Maximize upwards speed
	float yVelocity = CLAMP(_bird.physicsBody.velocity.dy, -1 * MAXFLOAT, 250.f);
	_bird.physicsBody.velocity = CGVectorMake(0, yVelocity);
}

#pragma mark GameObjects
- (void)startGame {
	// GameOver is false
	gameStarted = NO;
	GameOver = NO;
	
	// Score starts at 0
	score = 0;
	scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	
	scoreLabel.text = [NSString stringWithFormat:@"%i", score];
	scoreLabel.fontSize = 30;
	scoreLabel.position = CGPointMake(screenWidth / 2, screenHeight / 4 + screenHeight / 2);
	scoreLabel.zPosition = 3.0;
	[self addChild:scoreLabel];
	
	// Alloc Arrays
	bottomPipes = [NSMutableArray array];
	topPipes = [NSMutableArray array];
	
	[self createBackground];
	[self generatePipe];
	[self createGround];
	[self createBird];
	
	// World Gravity
	[self.physicsWorld setGravity:CGVectorMake(0.0, -4.0)];
	
	[self prepareSound];
	
	// Gliding
	direction = 1;
}

- (void)createBird {
	_bird = [SKSpriteNode spriteNodeWithImageNamed:@"bird1"];

	// Adding physics body to bird
	_bird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_bird.frame.size];
	_bird.physicsBody.affectedByGravity = NO;
	_bird.physicsBody.dynamic = NO;

	// Default position
	_bird.position = CGPointMake((screenWidth / 2) - 85, screenHeight / 2);
	_bird.zPosition = 4.0;

	// Adding bird to the layer
	[self addChild:_bird];
}

- (void)openWings {
	[_bird setTexture:[SKTexture textureWithImageNamed:@"bird1"]];
}

-(void)createBackground {
	NSArray *backgroudNames = @[@"flappybg.jpg", @"flappybg.jpg"];
	CGSize backgroundSize = CGSizeMake(screenWidth, screenHeight);
	background = [[FMMParallaxNode alloc] initWithBackgrounds:backgroudNames
																											 size:backgroundSize
																			 pointsPerSecondSpeed:20.0];
	background.position = CGPointMake(0, 0);
	background.zPosition = 0.0;
	[self addChild:background];
}

-(void)generatePipe {
	int i = arc4random() % 2;
	int j = arc4random() % 120;

	if(IS_IPHONE_5) {
		if(i == 0 && j < 40) {
			j = j * -1;
		}
	} else {
		if(i == 0 && j < 50) {
			j = j * -1;
		}
	}
	Obstacle *somePipe = [Obstacle spriteNodeWithImageNamed:@"pipe"];
	[somePipe setIsActive:YES];
	[somePipe setGavePoint:NO];
	somePipe.xScale = 0.20;
	somePipe.yScale = 0.50;
	somePipe.position = CGPointMake(screenWidth + somePipe.frame.size.width / 2, j);
	somePipe.zPosition = 1.0;
	[bottomPipes addObject:somePipe];
	[self addChild:somePipe];
	
	Obstacle *pipeTop = [Obstacle spriteNodeWithImageNamed:@"pipeTop"];
	[pipeTop setIsActive:YES];
	pipeTop.xScale = 0.20;
	pipeTop.yScale = 0.50;
	if(IS_IPHONE_5) {
		pipeTop.position = CGPointMake(somePipe.position.x +2, somePipe.position.y + (somePipe.size.height) + 90);
	} else {
		pipeTop.position = CGPointMake(somePipe.position.x +2, somePipe.position.y + (somePipe.size.height) + 100);
	}
	pipeTop.zPosition = 1.0;
	[topPipes addObject:pipeTop];
	[self addChild:pipeTop];
}

-(void)createGround {
	NSArray *groundNames = @[@"ground.png", @"ground.png"];
	CGSize groundSize = CGSizeMake(screenWidth, screenHeight / 5);
	ground = [[FMMParallaxNode alloc] initWithBackgrounds:groundNames
																									 size:groundSize
																	 pointsPerSecondSpeed:90.0];
	ground.position = CGPointMake(0, 0);
	ground.zPosition = 2.0;
	[self addChild:ground];
}

-(void)prepareSound {
	NSError *error;
	NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"jump" withExtension:@"wav"];
	NSURL *pointMusicURL = [[NSBundle mainBundle] URLForResource:@"point" withExtension:@"wav"];
	jumpSound = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
	pointSound = [[AVAudioPlayer alloc] initWithContentsOfURL:pointMusicURL error:&error];
	[jumpSound prepareToPlay];
	[pointSound prepareToPlay];
}

- (void)didCollide {
	_bird.zRotation = 180;
	GameOver = YES;
}

@end