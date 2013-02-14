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
    MyContactListener *contactListener;
    
    enum _entityCategory {
		BOUNDARY = 0x0001,
    	BOX =     0x0002,
    	BALL =     0x0004,
  	};
    
    enum _tags{
        TBOX, TBALL
    };
}

+(CCScene *) scene;
-(void)buildWalls:(CGSize)winSize;

@end
