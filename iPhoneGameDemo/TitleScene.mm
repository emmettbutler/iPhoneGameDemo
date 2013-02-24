#import "TitleScene.h"
#import "HelloWorldLayer.h"

@implementation TitleLayer

+(CCScene *) scene{
	CCScene *scene = [CCScene node];
	TitleLayer *layer = [TitleLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init{
    if ((self = [super init])){
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // create and add a background sprite to the layer
        CCSprite *sprite = [CCSprite spriteWithFile:@"bliss.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        // make some labels, one of which is a button
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"My Awesome iPhone Game!" fontName:@"Marker Felt" fontSize:32.0];
        CCMenuItem *button = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(switchScene)];
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        [menu setPosition:ccp(size.width / 2, size.height / 2)];
        [self addChild:menu];
        
        CCLabelTTF *byline = [CCLabelTTF labelWithString:@"By [your name here]" fontName:@"Marker Felt" fontSize:22.0];
        [byline setPosition:ccp((size.width/2), (size.height/2)-50)];
        [self addChild:byline];
    }
    return self;
}

// called when the title button is pressed
- (void)switchScene{
    // switch the scene (aka screen transition) from this one to [HelloWorldLayer scene], which contains our HelloWorldLayer instance
    CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[HelloWorldLayer scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

-(void) dealloc{
    [super dealloc];
}

@end