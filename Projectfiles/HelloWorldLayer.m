/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

@interface HelloWorldLayer (PrivateMethods)
@end

@implementation HelloWorldLayer


NSMutableArray *gameBoard;
NSMutableArray *neighbors;
bool go=false;

// to do: 
//
// add buttons to clear and start/stop. Use go var to control, by just
// skipping the logic if go is false
//
// add logic to avoid unecessary board checks: when a cell comes to life
// or dies, keep list of neighbors to be checked

const int BOARD_SIZE= 10;


-(id) init
{
	if ((self = [super init]))
	{		CCLOG(@"%@ init", NSStringFromClass([self class]));
		
		//CCDirector* director = [CCDirector sharedDirector];
        
        CCMenuItemFont *goButton = [CCMenuItemFont itemFromString:@"Start/Stop" target:self selector:@selector(changeGo)];
        CCMenuItemFont *clearButton = [CCMenuItemFont itemFromString:@"Clear" target:self selector:@selector(clearBoard)];
        
		CCMenu *myMenu = [CCMenu menuWithItems:goButton, clearButton, nil];
        [myMenu setPosition:ccp(150,400)];
        [self addChild:myMenu z:1];
        [myMenu alignItemsHorizontallyWithPadding:50];
        
        
        
        gameBoard=[self initialize2DArrayWithRandom];
        neighbors=[self initialize2DArray];
        [self updateNeighbors];

		[[SimpleAudioEngine sharedEngine] playEffect:@"Pow.caf"];
        [self schedule:@selector(evolve) interval: .1f];
        [self schedule:@selector(checkTouch) interval:.01f];
	}

	return self;
}

-(NSMutableArray *) initialize2DArray
{
    
    NSMutableArray* myArray=[[NSMutableArray alloc] init]; //this initializes the array
    for (int k = 0; k < BOARD_SIZE; ++ k)
    {
        NSMutableArray* subArr=[[NSMutableArray alloc] init];
        for (int s = 0; s < BOARD_SIZE; ++ s)
        {
            
            NSNumber *item = [NSNumber numberWithInt: 0];
            [subArr addObject:item];
            
        }
        [myArray addObject:subArr];
    }
    return myArray;
}
-(NSMutableArray *) initialize2DArrayWithRandom
{
    
    NSMutableArray* myArray=[[NSMutableArray alloc] init]; //this initializes the array
    for (int k = 0; k < BOARD_SIZE; ++ k)
    {
        NSMutableArray* subArr=[[NSMutableArray alloc] init];
        for (int s = 0; s < BOARD_SIZE; ++ s)
        {
            int i=arc4random_uniform(2);
            NSNumber *item = [NSNumber numberWithInt: i];
            [subArr addObject:item];
            
        }
        [myArray addObject:subArr];
    }
    return myArray;
}

-(void) updateNeighbors
{
    for (int i=0; i<BOARD_SIZE; i++)
    {
        NSMutableArray* row=[gameBoard objectAtIndex:i];
        for (int j=0; j<BOARD_SIZE; j++)
        {
            int count=0;
            if (j>0)
            {
                if ([[row objectAtIndex:(j-1)] integerValue ]==1)
                {
                    count++;
                }
                if (i>0)
                {
                    if ([[[gameBoard objectAtIndex:i-1]
                          objectAtIndex:(j-1)]
                         integerValue ]==1)
                    {
                        count++;
                    }
                }
                if (i<BOARD_SIZE-1)
                {
                    if ([[[gameBoard objectAtIndex:i+1]
                          objectAtIndex:(j-1)]
                         integerValue ]==1)
                    {
                        count++;
                    }
                }
            }
            if (j<BOARD_SIZE-1)
            {
                if ([[row objectAtIndex:(j+1)] integerValue ]==1)
                {
                    count++;
                }
                if (i>0)
                {
                    if ([[[gameBoard objectAtIndex:i-1]
                          objectAtIndex:(j+1)]
                         integerValue ]==1)
                    {
                        count++;
                    }
                }
                if (i<BOARD_SIZE-1)
                {
                    if ([[[gameBoard objectAtIndex:i+1]
                          objectAtIndex:(j+1)]
                         integerValue ]==1)
                    {
                        count++;
                    }
                }
            }
            if (i>0)
            {
                if ([[[gameBoard objectAtIndex:i-1]
                      objectAtIndex:(j)]
                     integerValue ]==1)
                {
                    count++;
                }
            }
            
            if (i<BOARD_SIZE-1)
            {
                if ([[[gameBoard objectAtIndex:i+1]
                      objectAtIndex:(j)]
                     integerValue ]==1)
                {
                    count++;
                }
            }
            [self changeValueOfArray:neighbors atI:i j:j to:count];
        }
    }

}

-(void) changeValueOfArray:(NSMutableArray *)array atI:(int) i j:(int) j to: (int) newValue
{
    NSMutableArray* row=[array objectAtIndex:i];
    [row replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:newValue]];
    [array replaceObjectAtIndex:i withObject:row];
}

-(void) changeGo
{
    go=!go;
}

-(void) clearBoard
{
    gameBoard=[self initialize2DArray];
    neighbors=[self initialize2DArray];
}

-(void) ccFillPoly: (CGPoint*) poli: (int) points: (BOOL) closePolygon
{
    
    // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
    
    // Needed states: GL_VERTEX_ARRAY,
    
    // Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, poli);
    if( closePolygon )
        glDrawArrays(GL_TRIANGLE_FAN, 0, points);
    else
        glDrawArrays(GL_LINE_STRIP, 0, points);
    
    // restore default state
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
}

-(void)drawSquareAtXindex: (int)xIdx yIndex:(int)yIdx
{
    CCDirector* director = [CCDirector sharedDirector];
    //enable an opengl setting to smooth the line once it is drawn
    glEnable(GL_LINE_SMOOTH);
    
    //set the color in RGB to draw the line with
    glColor4ub(255,255,255,255);
    
    //convert indices to points
    CGSize windowSize=[director winSize];
    CGFloat xDimension=windowSize.width;
    CGFloat yDimension=windowSize.height;
    
    CGFloat minDimension=MIN(xDimension, yDimension);
    
    CGFloat leftX= xIdx * minDimension/BOARD_SIZE;
    CGFloat rightX= (xIdx+1) * minDimension/BOARD_SIZE;
    CGFloat bottomY= yIdx * minDimension/BOARD_SIZE;
    CGFloat topY= (yIdx+1) * minDimension/BOARD_SIZE;
    
    //now let's draw a filled-in polygon! Here are the 4 vertices
    CGPoint bottomLeft = ccp(leftX,bottomY);
    CGPoint bottomRight = ccp(rightX,bottomY);
    CGPoint topLeft = ccp(leftX,topY);
    CGPoint topRight = ccp(rightX,topY);
    
    //now we put these vertices in an array
    CGPoint vertices[] = {bottomLeft, bottomRight, topRight, topLeft};
    
    //and now we draw a filled-in polygon with those vertices
    [self ccFillPoly:vertices: 4: TRUE];
    
}

-(void) evolve
{
    if (go)
    {
        for (int i=0; i<BOARD_SIZE; i++)
        {
            for (int j=0; j<BOARD_SIZE; j++)
            {
                int cellState=[[[gameBoard objectAtIndex:i] 
                                 objectAtIndex:j] 
                                integerValue];
                if (cellState==1)
                {
                    if (([[[neighbors objectAtIndex:i] 
                          objectAtIndex:j] 
                         integerValue]<2) ||
                        ([[[neighbors objectAtIndex:i] 
                         objectAtIndex:j] 
                          integerValue]>3)) 
                    {
                        [self changeValueOfArray:gameBoard atI:i j:j to:0];
                    }
                }
                if (cellState==0)
                {
                   if( [[[neighbors objectAtIndex:i] 
                         objectAtIndex:j] 
                        integerValue]==3)
                   {
                       [self changeValueOfArray:gameBoard atI:i j:j to:1];
                   }
                }
            }
        }
        
    [self updateNeighbors];
    }
}

-(void) checkTouch
{
    
    if (!go && [[KKInput sharedInput] anyTouchBeganThisFrame])
    {
        CGPoint touchLocation=[[KKInput sharedInput] anyTouchLocation];
        [self changeCellAtLocation:touchLocation];
    }
}

-(void) changeCellAtLocation:(CGPoint) location
{
    int width=[[CCDirector sharedDirector] winSize].width;
    int height=[[CCDirector sharedDirector] winSize].height;
    int minDimension=MIN(width, height);
    if (location.x<minDimension 
        &&
        location.y<minDimension)
    {
        int xIdx=location.x/(minDimension/BOARD_SIZE);
        int yIdx=location.y/(minDimension/BOARD_SIZE);
        
        int newValue=0;
        if ([[[gameBoard objectAtIndex:xIdx] 
              objectAtIndex:yIdx]
             integerValue] ==0)
        {
            newValue=1;
        }
        [self changeValueOfArray:gameBoard atI:xIdx j:yIdx to:newValue];
        [self updateNeighbors];
    }
}

-(void) draw
{
    for (int i=0; i<BOARD_SIZE; i++)
    {
        NSMutableArray* row=[gameBoard objectAtIndex:i];
        for (int j=0; j<BOARD_SIZE; j++)
        {
            int cellState=[[row objectAtIndex:j] integerValue];
            if (cellState==1) [self drawSquareAtXindex:i yIndex:j];
        }
    }
}
@end
