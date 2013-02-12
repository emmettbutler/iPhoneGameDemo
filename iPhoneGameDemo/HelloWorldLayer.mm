//
//  HelloWorldLayer.mm
//  iPhoneGameDemo
//
//  Created by Emmett Butler on 2/11/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

#define PTM_RATIO 32

@implementation HelloWorldLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		bool doSleep = true;
		
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		m_debugDraw->SetFlags(flags);
        
        [self buildWalls:screenSize];
		
        // Create sprite and add it to the layer
        CCSprite *ball = [CCSprite spriteWithFile:@"Bagel.png"];
        ball.position = ccp(100, 100);
        ball.tag = 1;
        [self addChild:ball z:9];
        
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 180/PTM_RATIO);
        ballBodyDef.userData = ball;
        b2Body * ballBody = world->CreateBody(&ballBodyDef);
        
        b2CircleShape circle;
        circle.m_radius = ball.contentSize.width/2/PTM_RATIO;
        
        b2Fixture *_ballFixture;
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 10.0f;
        ballShapeDef.friction = 0.f;
        ballShapeDef.userData = (void *)1;
        ballShapeDef.restitution = 0.8f;
        _ballFixture = ballBody->CreateFixture(&ballShapeDef);
        
        b2Vec2 force = b2Vec2(38.3f,30.9f);
        ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_default.png"];
        [self addChild:spritesheet];
        
        NSMutableArray *flyAnimFrames = [NSMutableArray array];
        [flyAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ChiDog.png"]];
        for(int i = 1; i <= 5; ++i){
            [flyAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"ChiDog_Shot_%d.png", i]]];
        }
        
        NSMutableArray *hitAnimFrames = [NSMutableArray array];
        [hitAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ChiDog.png"]];
        hitAnim = [CCAnimation animationWithFrames:hitAnimFrames delay:0.1f];
        flyAnim = [CCAnimation animationWithFrames:flyAnimFrames delay:0.9f];
				
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) buildWalls:(CGSize)winSize{
    // Create edges around the entire screen
    b2Fixture *_bottomFixture;
    b2Body *_groundBody;
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    _groundBody = world->CreateBody(&groundBodyDef);
    b2PolygonShape groundBox;
    b2FixtureDef groundBoxDef;
    groundBoxDef.shape = &groundBox;
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
    _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,
                                                                    winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                        b2Vec2(winSize.width/PTM_RATIO, 0));
    _groundBody->CreateFixture(&groundBoxDef);
}

-(void) draw{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}


-(void) tick: (ccTime) dt{
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	world->Step(dt, velocityIterations, positionIterations);

	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()){
		if (b->GetUserData() != NULL){
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	}
}

- (void) dealloc{
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	[super dealloc];
}
@end
