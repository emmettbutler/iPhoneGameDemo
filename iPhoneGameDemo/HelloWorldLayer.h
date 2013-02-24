#import "MyContactListener.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface HelloWorldLayer : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    CCSpriteBatchNode *spritesheet;
    CCAction *_flyAction;
    CCFiniteTimeAction *_hitAction;
    CCAnimation *flyAnim, *hitAnim;
    b2Vec2 gravity;
    MyContactListener *contactListener;
    
    // boolean flags denoting collision filtering categories
    // these *must* be independent with respect to the boolean AND operation to work properly
    // that is, the result of ANDing all of these categories together must be 0
    // you've been warned
    enum _entityCategory {
		BOUNDARY = 0x0001,  // 0001
    	BOX =     0x0002,   // 0010
    	BALL =     0x0004,  // 0100
  	};
    
    enum _tags{
        TBOX, TBALL
    };
}

+(CCScene *) scene;
-(void)buildWalls:(CGSize)winSize;

@end
