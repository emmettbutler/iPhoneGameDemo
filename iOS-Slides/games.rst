.. include:: <s5defs.txt>

=================================
Basics of iPhone Game Development
=================================

:Author:  Emmett Butler
:Date:    $Date: 2013-02-20 22:52:00 -0500 (Wed, 20 Feb 2013) $

.. This document is copyright Emmett Butler

.. container:: handout

    **How this was made**

    This document was created using Docutils_/reStructuredText_ and S5_.

.. _Docutils: http://docutils.sourceforge.net/
.. _reStructuredText: http://docutils.sourceforge.net/rst.html
.. _S5: http://meyerweb.com/eric/tools/s5/

Read slides on your own
-----------------------

http://github.com/emmett9001/iPhoneGameDemo

http://emmettbutler.com/basic-ios-slides/games.html

Meta
----

**Me**: I'm a Python devotee who learned Objective-C out of necessity. I'm also skilled in Javascript, C/C++ and OpenGL. I love video games and elegant code.

**Professionally**: I've worked part- and full-time at Parsely since 2011, concentrating primarily on web scraping and semantic metadata (see http://schema.to). With my game design partner, I shipped Heads Up Hot Dogs for iOS, published by [adult swim] Games, in October 2012.

**E-mail me**: emmett.butler321@gmail.com

**My website**: emmettbutler.com_

**Follow me on Twitter**: emmett9001_

**Follow me on Github**: github_

.. _emmettbutler.com: http://emmettbutler.com
.. _emmett9001: http://twitter.com/emmett9001
.. _github: http://github.com/emmett9001

iOS Flyover
-----------

.. class:: incremental

    Development environment: Mac exclusive, XCode all the way down

    Language of choice: Objective-C, C, C++

    Frameworks: Foundation, UIKit, OpenGL ES

The "Zen" of Objective-C?
-------------------------

.. class:: incremental

    NeXT/Apple's response to object-orientation

    Layer atop C and C++ - superset

    Adds
        * classes, inheritance
        * runtime reflection
        * Smalltalk-style message passing

iPhone Game Technologies
------------------------

**Cocos2D**: 2D sprite animation and time-based action system

**Box2D**: 2D rigid body dynamics simulation (aka physics engine)

**Zwoptex**: Free tool for packing sprite images into spritesheets

Cocos2D
-------

.. class:: incremental

    Object-oriented library facilitating common game-related graphics tasks

    Sprite animation, screen transitions, time-based actions and particle effects are the most prominent

    Built on OpenGL ES (handles the actual drawing)

    Integrates box2d

    Free and open-source(!!) - but read the license

Box2D
-----

.. class:: incremental

    State machine ("world") with input and output ports

    Implemented as a C++ library - this works since Objective-C is a *strict superset* of C++

    Main purpose is to perform physical calculations very fast

    Contains modules for drawing the simulated objects to the screen (DebugDraw)

    Also free and open-source

.. QUESTIONS!??

Cocos2D API Overview
--------------------

.. class:: incremental

    **CCDirector** is the main controller singleton - handles scenes and OpenGL communications

    A game (handled by CCDirector) consists of one or more **CCScenes**

    Scenes consist of one or more **CCLayers**

    Layers consist of one or more **CCSprites**

    **Generalization**: All of these classes (with the exception of CCDirector) are subclasses of **CCNode**.

Scene Graph
-----------

.. image:: img/scenegraph.png

Scenes transition to other scenes via predefined transition functions

.. source: http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:basic_concepts

CCNode
------

.. class:: incremental

    Base class for almost every Cocos object

    Defines many standard properties like z index, position, dimensions

    Since all classes inherit from CCNode, it's easy to create graphical tree structures

CCLayer
-------

A scene consists of several layers, each z-indexed to create a stack

.. image:: img/layers.png

Layers handle user input (touch, accelerometer) and contain sprites, layers (other Nodes)

.. source: http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:basic_concepts

CCSprite
--------

.. class:: incremental

    Abstraction built around a 2D image drawn to the screen by OpenGL ES

    Knows its position in an orthogonal coordinate system with the origin at bottom-left

    Can be instantiated with a single image (bad) or with a spritesheet image/plist combination (good)

Why Spritesheets?
-----------------

.. class:: incremental

    Underneath the abstraction, OpenGL loads each image you tell Cocos2D about as an individual texture

    Textures are essentially raw image data that OpenGL knows how to draw on geometry

    and they're very memory-intensive

    The fewer images you give to Cocos2D, the better

.. example of expensive: the Playstation Vita can only handle ~200 512x512 textures in memory at one time

CCSpriteBatchNode
-----------------

.. class:: incremental

    Solution: put all of our sprites in one big image file, load it as a texture, and have OpenGL cut the sprites out of that texture as needed

    Zwoptex - sprite packing tool

    Creates a .png image containing all sprites

    Also creates a .plist defining the bounding boxes around sprites, complete with the original filenames

Loading a spritesheet
---------------------

This allows us to do things like

.. sourcecode:: objective-c

    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"my.plist"];
    CCSpriteBatchNode *spritesheet = [CCSpriteBatchNode batchNodeWithFile:@"my.png"];
    CCSprite *mySprite = [CCSprite spriteWithSpriteFrameName:@"dummy.png"];  //*

.. isn't objective-c fun?

Tell cocos about the sprite frames plist, then give it the png image to slice up

We can then reference the sprite images by name!

Also supports uniform spritesheets (those without accompanying metadata)

Gotchas
-------

You can load multiple spritesheets at once, but beware namespace collisions

A sprite frame whose name is already in the cache will be overwritten

Leads to unpredictable results

Sprite frames are cached locally, so frame/image mismatches can occur:

.. image:: img/bugs.png

Playing with Time
-----------------

.. class:: incremental

    CCAction and CCAnimation are the two main base classes

    CCAnimation is a container of animation frame images (think flipbook)

    CCAction is a more general time handling class

Creating an Animation Action
----------------------------

.. sourcecode:: objective-c

    NSMutableArray *frames = [NSMutableArray array];
    CCAnimation *anim = [CCAnimation animationWithFrames:frames delay:0.1f];
    CCAction *action = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
    [mySprite runAction:action];  //*

Create an array of spriteframes, create animation, create action, run the action

Sequential Actions
------------------

.. sourcecode:: objective-c

    [sprite runAction:
        [CCSequence actions:myAction,
        [CCCallFuncN actionWithTarget:self selector:@selector(runLoop:)],
        nil]
    ];

Here, we run a compound action (CCSequence) that plays an action, then calls the runLoop function

Touch Input
-----------

Cocos provides callbacks for touch beginnings, movement, and endings.

.. sourcecode:: objective-c

    - (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
        for( UITouch *touch in touches ) {
            CGPoint location = [touch locationInView: [touch view]];
            location = [[CCDirector sharedDirector] convertToGL: location];
        }
    }  //*

Example of getting the Cocos coordinate space location of the touch events currently ending

.. QUESTIONS!??

Box2D
-----

.. class:: incremental

    Recall: C++ rigid body dynamics simulation

    Less of an API, more of a state machine

    First problem: interfacing Objective-C Cocos2d code with C++ Box2d

    End up wrapping box2d pointers in Obj-C NSValues *a lot*

Box2D API Overview
------------------

.. class:: incremental

    Main entry point to the simulation: b2World class

    **World** contains **bodies** - containers for fixtures

    **Fixtures** are main workhorses - convex polygons with restitution, density, mass, friction, etc.

    **Joints** connect bodies to each other

    **Impulses** are forces that can be applied to bodies

b2World
-------

Contains an iterator over all of the bodies it contains

Defines gravity and other global properties

.. sourcecode:: c++

    b2World *world = new b2World(-30.0f, true);  //*

Sets the gravity of the world

b2Body
------

Container for fixtures, which are the ones that do the colliding

Properties include type (dynamic/static), position, and userdata

.. sourcecode:: objective-c

    b2BodyDef boxBodyDef;
    boxBodyDef.type = b2_dynamicBody;
    boxBodyDef.position.Set(location.x/PTM_RATIO, location.y/PTM_RATIO);
    boxBodyDef.userData = sprite;
    b2Body *boxBody = world->CreateBody(&boxBodyDef);  //*

Creating a body from a definition

b2Fixture
---------

Have shapes, perform collisions, bounce, slide

Many per body

.. sourcecode:: c++

    b2FixtureDef boxShapeDef;
    boxShapeDef.shape = &boxShape;
    boxShapeDef.density = 10.0f;
    boxShapeDef.friction= 0.4f;
    boxShapeDef.restitution = 0.9f;

Collision Filtering
-------------------

.. class:: incremental

    Boolean flags are used for collision filtering

    Fixtures have a category and a mask

    Category: "what am I"

    Mask: "What can I collide with?"

Collision Bits
--------------

.. sourcecode:: c++

    enum _entityCategory {
        BOUNDARY = 0x0001,  // 001
        BOX =     0x0002,   // 010
        BALL =     0x0004,  // 100
    };

    boxShapeDef.filter.categoryBits = BOX;
    boxShapeDef.filter.maskBits = BALL | BOUNDARY;

On collision, the mask and category bits of each fixture are &'ed

If the result is nonzero, collision is registered

.. QUESTIONS!??

Making Box and Cocos Play Together
----------------------------------

Single most important snippet to understand

.. sourcecode:: objective-c

    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()){
        if (b->GetUserData() != NULL){
            CCSprite *myActor = (CCSprite*)b->GetUserData();
            myActor.position = CGPointMake(b->GetPosition().x*PTM_RATIO,
                        b->GetPosition().y*PTM_RATIO);
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    } //*

Set a sprite as the userData of its corresponding body, then update its position each frame based on the body

Other Gotchas
-------------

.. class:: incremental

    Box2d and Cocos2d both use orthogonally-projected coordinate systems with the origin at the bottom-left

    However, Cocos2D deals in pixels and Box2d uses meters

    Setting a sprite's position to 200x200 meters will put it far offscreen

    Define a constant PTM_RATIO = 32 -> 32 pixels to a meter

    Divide/multiply by this to convert units

Defining a class (HotDog.h)
---------------------------

Enforced separation of @interface and @implementation

.. sourcecode:: objective-c

    @interface HotDog : NSObject {
        b2World *world;
        CCSpriteBatchNode *spritesheet;
        CGSize winSize;
        b2Body *worldBody;

        CCSprite *sprite1;
        BOOL touched, exploding, grabbed, hasTouchedHead;
        ccColor3B _color_pink;
    }

    -(HotDog *)initWithBody:(NSValue *)b;
    -(NSValue *)getBody; //*

    @end

.. a typical class representing a game object

Useful links
------------

Box2d manual_

Cocos2d guide_

Ray Wenderlich's blog_

Box2d tutorial_

.. _manual: http://www.box2d.org/manual.html
.. _guide: http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:index
.. _blog: http://www.raywenderlich.com/
.. _tutorial: http://www.iforce2d.net/b2dtut/

Fin!
----

I'm your host, Emmett Butler

http://github.com/emmett9001

http://emmettbutler.com

http://headsuphotdogs.com
