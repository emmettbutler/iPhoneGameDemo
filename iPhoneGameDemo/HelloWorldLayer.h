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
    b2Fixture *_ballFixture;
}

+(CCScene *) scene;

@end
