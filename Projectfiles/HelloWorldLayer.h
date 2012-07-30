/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

@interface HelloWorldLayer : CCLayer
{

}

-(NSMutableArray *) initialize2DArray;

-(void) ccFillPoly: (CGPoint*) poli: (int) points: (BOOL) closePolygon;

-(void)drawSquareAtXindex: (int)xIdx yIndex:(int)yIdx;
@end
