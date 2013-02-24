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
#define VELOCITY_MULT 115

@implementation HelloWorldLayer

// this method is called from the TitleScene when screen transition is initiated
+(CCScene *) scene{
    // create a new default scene
	CCScene *scene = [CCScene node];
    // create our layer (node eventually calls init)
	HelloWorldLayer *layer = [HelloWorldLayer node];
    // add our layer to the scene we made
	[scene addChild: layer];
	return scene;
}

// put a single box body and sprite on the screen at a given position with a given velocity
-(void)putBox:(CGPoint)location xVel:(float)xVel yVel:(float)yVel{
    CCLOG(@"Add sprite %0.2f x %02.f",location.x,location.y);
    
    // make the sprite using a spritesheet, not a single file
    CCSprite *_box = [CCSprite spriteWithSpriteFrameName:@"ChiDog.png"];
    _box.position = ccp( location.x, location.y);
    _box.tag = TBOX;
    
    // define CCActions that use the animation objects we made in init
    _hitAction = [[CCAnimate actionWithAnimation:hitAnim restoreOriginalFrame:YES] retain];
    _flyAction = [[CCRepeatForever actionWithAction:
                      [CCAnimate actionWithAnimation:flyAnim restoreOriginalFrame:NO]] retain];
    
    // run the one called flyAction
    [_box runAction:_flyAction];
    // add the box sprite to the scene
    [spritesheet addChild:_box];
    
    // standard body-creation idiom for box2d: make a body, give it a fixture
    b2Body *boxBody;
    b2BodyDef boxBodyDef;
    boxBodyDef.type = b2_dynamicBody;
    boxBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    boxBodyDef.userData = _box;  // assign the sprite we just made to be the body's userdata, so we can move them around together
    boxBody = world->CreateBody(&boxBodyDef);
    
    b2PolygonShape boxShape;
    boxShape.SetAsBox(_box.contentSize.width/PTM_RATIO/2,
                      _box.contentSize.height/PTM_RATIO/2);
    
    b2Fixture *boxFixture;
    b2FixtureDef boxShapeDef;
    boxShapeDef.shape = &boxShape;
    boxShapeDef.density = 10.0f;
    boxShapeDef.friction= 0.4f;
    boxShapeDef.restitution = 0.9f;
    boxShapeDef.userData = (void *)TBOX;
    boxShapeDef.filter.categoryBits = BOX;
    boxShapeDef.filter.maskBits = BALL | BOUNDARY;
    boxFixture = boxBody->CreateFixture(&boxShapeDef);
    
    b2Vec2 force = b2Vec2(xVel, yVel);
    boxBody->ApplyLinearImpulse(force, boxBodyDef.position);
}

// called as part of the [HelloWorldLayer node] constructor above
// perform one-time initialization of the layer
-(id) init{
    // common objective-c idiom for calling a parent constructor (in this case, CCLayer)
	if( (self=[super init])) {
        // cocos flags for touch and accelerometer
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
        // find and store the size of the window for later user
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // make two labels, put each one on a button
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Gravity" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *gravityButton = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(toggleGravity)];
        label = [CCLabelTTF labelWithString:@"Debug draw" fontName:@"Marker Felt" fontSize:18.0];
        CCMenuItem *debug = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(debugDraw)];  // calls toggleGravity when touched
		// add buttons to a menu
        CCMenu *menu = [CCMenu menuWithItems:gravityButton, debug, nil];
        [menu alignItemsVertically];
        [menu setPosition:ccp(60, screenSize.height-65)];
        // add menu to the layer, making it visible
        [self addChild:menu];
        
        // create a vector to use as gravity
		gravity.Set(0.0f, -10.0f);
		
		bool doSleep = true;
		
        // create the box2d physics world with our gravity vector
		world = new b2World(gravity, doSleep);
		world->SetContinuousPhysics(true);
		
        // tell box2d to draw shapes
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		m_debugDraw->SetFlags(flags);
        
        // call our buildWalls function to assemble the collideable walls
        [self buildWalls:screenSize];
		
        // MAKING A PHYSICS BODY WITH CORRESPONDING SPRITE
        
        // Create sprite and add it to the layer
        CCSprite *ball = [CCSprite spriteWithFile:@"Bagel.png"];
        ball.position = ccp(100, 100);
        ball.tag = TBALL;
        [self addChild:ball z:9];
        
        // Create ball body and fixture
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 180/PTM_RATIO);  // convert from pixels to meters (since we think in pixels typically)
        ballBodyDef.userData = ball;  // give the body a permanent reference to the sprite, so they move together
        b2Body * ballBody = world->CreateBody(&ballBodyDef);
        
        b2CircleShape circle;
        circle.m_radius = ball.contentSize.width/2/PTM_RATIO;
        
        b2Fixture *_ballFixture;
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 10.0f;
        ballShapeDef.friction = 0.f;
        ballShapeDef.restitution = 0.8f;  // how much of my energy is retained after a bounce
        ballShapeDef.userData = (void *)TBALL;
        ballShapeDef.filter.categoryBits = BALL;  // I am a BALL
	    ballShapeDef.filter.maskBits = BOX | BOUNDARY;  // I may collide with BOXes and BOUNDARYs
        _ballFixture = ballBody->CreateFixture(&ballShapeDef);
        
        // push the ball along the given vector "force"
        b2Vec2 force = b2Vec2(38.3f,30.9f);
        ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
        
        
        // SRITESHEET AND ANIMATION SETUP
        
        // tell cocos2d about the sprite metadata (plist) file
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"sprites_default.plist"];
        // load corresponding png spritesheet into graphics memory
        spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"sprites_default.png"];
        [self addChild:spritesheet];
        
        // create an array of animation frames
        NSMutableArray *flyAnimFrames = [NSMutableArray array];
        // add one frame of animation (a sprite) to the array
        [flyAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ChiDog.png"]];
        
        // create another array of frames
        NSMutableArray *hitAnimFrames = [NSMutableArray array];
        // sequentially add five different sprites to the array, to be used as animation frames
        for(int i = 1; i <= 5; ++i){
            [hitAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"ChiDog_Shot_%d.png", i]]];
        }
        
        // now that we have animation frame arrays, use them to construct cocos2d Animation objects
        hitAnim = [[CCAnimation animationWithFrames:hitAnimFrames delay:0.1f] retain];
        flyAnim = [[CCAnimation animationWithFrames:flyAnimFrames delay:0.12f] retain];
        
        // call putBox a bunch of times, sending it a series of velocity vectors that trace out a circle
        for(float i = 0.0f; i < 2*M_PI; i += M_PI/8){
            [self putBox:CGPointMake(screenSize.width/2, screenSize.height/2) xVel:VELOCITY_MULT*sin(i) yVel:VELOCITY_MULT*cos(i)];
        }
        
        // create our box2d contact listener and tell box2d about it
        contactListener = new MyContactListener();
		world->SetContactListener(contactListener);
				
        // have tick: run many times per second from here on
        // init makes this call asynchronously and returns immediately
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) buildWalls:(CGSize)winSize{
    // Create edges around the entire screen
    // screen walls are modeled as one body with four fixtures:
    b2Fixture *_bottomFixture;
    b2Body *_groundBody;
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    _groundBody = world->CreateBody(&groundBodyDef);
    b2PolygonShape groundBox;
    b2FixtureDef groundBoxDef;
    groundBoxDef.shape = &groundBox;
    groundBoxDef.userData = (void*)999;
    // fixture 1: screen bottom edge
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
    _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
    // fixture 2: screen left edge
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    // ficture 3: screen top edge
    groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,
                                                                    winSize.height/PTM_RATIO));
    _groundBody->CreateFixture(&groundBoxDef);
    // fixture 4: screen right edge
    groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                        b2Vec2(winSize.width/PTM_RATIO, 0));
    _groundBody->CreateFixture(&groundBoxDef);
}

-(void) draw{
    // called by cocos2d, this sets some opengl flags that box2d needs to draw its debug data...
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
    // tells box2d to draw it....
	world->DrawDebugData();
	
    // and restores the initial values of the opengl flags
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

// this is called on collisions after the box collision animation has played
-(void)runBoxLoop:(id)sender{
    // assume the sender is a sprite
    CCSprite *sprite = (CCSprite *)sender;
    // re-create an infinitely looping animation action object and run it
    _flyAction = [CCRepeatForever actionWithAction:
                      [CCAnimate actionWithAnimation:flyAnim restoreOriginalFrame:NO]];
    [sprite runAction: _flyAction];
}

// called on button press, turns gravity on and off
-(void)toggleGravity{
    if(gravity.y < 0){
        gravity = b2Vec2(0,0);
    } else {
        gravity = b2Vec2(0,-30);
    }
    world->SetGravity(gravity);
}

// called on button press, turns box2d drawing on and off
-(void)debugDraw{
    if(!m_debugDraw){
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        uint32 flags = 0;
        flags += b2DebugDraw::e_shapeBit;
        flags += b2DebugDraw::e_jointBit;
        flags += b2DebugDraw::e_aabbBit;
        flags += b2DebugDraw::e_pairBit;
        flags += b2DebugDraw::e_centerOfMassBit;
        m_debugDraw->SetFlags(flags);
    } else {
        m_debugDraw = nil;
    }
    world->SetDebugDraw(m_debugDraw);
}

-(void) tick: (ccTime) dt{
    // move the physics world along
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(dt, velocityIterations, positionIterations);

    // for each body, move its associated sprite (userdata) to the body's current position and rotation
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()){
		if (b->GetUserData() != NULL){
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
    
    // for all currently happening collisions between bodies
    std::set<b2Body*>::iterator pos;
	for(pos = contactListener->contacts.begin(); pos != contactListener->contacts.end(); ++pos){
        b2Body *body = *pos;
        
		CCNode *contactNode = (CCNode*)body->GetUserData();
        CCSprite *sprite = (CCSprite *)body->GetUserData();
        CGPoint position = contactNode.position;
        
        // if there is a box involved in the collision
        if(sprite.tag == TBOX){
            [sprite stopAllActions];
            // animate the box exploding
            [sprite runAction:[CCSequence actions:_hitAction,
                               [CCCallFuncN actionWithTarget:self selector:@selector(runBoxLoop:)],nil]];

            // create and play a particle effect
            CCParticleSun* explosion = [[CCParticleSun alloc] initWithTotalParticles:40];
            explosion.autoRemoveOnFinish = YES;
            explosion.startSize = 1.0f;
            explosion.speed = 70.0f;
            explosion.anchorPoint = ccp(0.5f,0.5f);
            explosion.position = position;
            explosion.duration = 0.2f;
            [self addChild:explosion z:11];
            [explosion release];
        }
    }
    contactListener->contacts.clear();
}

// cocos2d callback, called when a finger is removed from the screen
// remove all of the boxes and put some new ones at the touch position
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	for( UITouch *touch in touches ) {
        // get the location of the touch that was just removed from the screen
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        
        // find all of the bodies tagged as TBOX (aka find all of the boxes)...
        for (b2Body* body = world->GetBodyList(); body; body = body->GetNext()){
            if (body->GetUserData() != NULL) {
                CCSprite *sprite = (CCSprite *)body->GetUserData();
                if(sprite.tag == TBOX){
                    // remove them
                    world->DestroyBody(body);
                    // and their associated sprites
                    [sprite removeFromParentAndCleanup:YES];
                }
            }
        }
        
        // put some new box bodies on the screen in their place
        for(float i = 0.0f; i < 2*M_PI; i += M_PI/8){
            [self putBox:location xVel:VELOCITY_MULT*sin(i) yVel:VELOCITY_MULT*cos(i)];
        }
	}
}

// manual memory managemenet - called when the CCDirector decides the scene should be removed
// AKA when user switches away from the scene
- (void) dealloc{
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	[super dealloc];
}
@end
