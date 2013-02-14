#include "MyContactListener.h"
#include "HelloWorldLayer.h"
#include "cocos2d.h"

MyContactListener::MyContactListener() : contacts(){
	
}

MyContactListener::~MyContactListener(){
	
}

void MyContactListener::BeginContact(b2Contact* contact){
	
}

void MyContactListener::EndContact(b2Contact* contact){
	
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold){
	
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse){
	bool isABall = contact->GetFixtureA()->GetUserData() == (void*)TBALL;
	bool isBBall = contact->GetFixtureB()->GetUserData() == (void*)TBALL;
	bool isABox = contact->GetFixtureA()->GetUserData() == (void*)TBOX;
	bool isBBox = contact->GetFixtureB()->GetUserData() == (void*)TBOX;
    
	if((isABall && isBBox) || (isBBall && isABox)){
		contacts.insert(contact->GetFixtureA()->GetBody());
		contacts.insert(contact->GetFixtureB()->GetBody());
	}
}