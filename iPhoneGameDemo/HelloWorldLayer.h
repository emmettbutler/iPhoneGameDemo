//
//  HelloWorldLayer.h
//  iPhoneGameDemo
//
//  Created by Emmett Butler on 2/11/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface HelloWorldLayer : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    CCSpriteBatchNode *spritesheet;
    CCAction *_flyAction, *_hitAction;
    CCAnimation *flyAnim, *hitAnim;
    
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
