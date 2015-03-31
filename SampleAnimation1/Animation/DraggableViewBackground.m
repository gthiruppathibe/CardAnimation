//
//  DraggableViewBackground.m

//

#import "DraggableViewBackground.h"


@interface DraggableViewBackground()

@property (nonatomic) CGRect initialDesignFrame;

@end

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    NSMutableArray *cardsView;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 3; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 400; //%%% height of the draggable card
static const float CARD_WIDTH = 335; //290 //%%% width of the draggable card

@synthesize exampleCardLabels,delegate; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards
@synthesize initialDesignFrame = _initialDesignFrame;


- (CGRect)initialDesignFrame {
    _initialDesignFrame = CGRectMake(20, 72, self.frame.size.width-40, self.frame.size.height/2);
    return _initialDesignFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        exampleCardLabels = [[NSArray alloc]initWithObjects:@"first",@"second",@"third",@"fourth",@"last", nil]; //%%% placeholder for card-specific information
        
        NSLog(@"Prayer Request Count=%lu",(unsigned long)[exampleCardLabels count]);
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsView = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        
        
        [self loadCards];
    }
    return self;
}
-(void)cardPinch:(float)yValue :(UIPanGestureRecognizer *)panGesture
{
    [delegate draggableTableCall];
    
}
-(void)cardTap
{
    [delegate pushPrayerDetailVC];
}

-(CGRect)designFrame:(NSInteger)index {
    CGRect frame ;
    
    
    
    frame = CGRectMake(0, 0,  self.frame.size.width, self.frame.size.height);
    
    NSLog(@"Design Frame: %@",NSStringFromCGRect(frame));
    NSLog(@"Self Frame:%@",NSStringFromCGRect(self.frame));
    return frame;
    
}

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    
    DraggableView *draggableView=[[DraggableView alloc]initWithData:[exampleCardLabels objectAtIndex:index]
                                                              frame:[self designFrame:index]
                                                    DesignViewFrame:[self designFrame:index]];
    
//    if (index !=0) {
//         draggableView.alpha =0.5;
//    }else{
//       
//    }
    draggableView.delegate = self;
    draggableView.delegateGrid=self;
  //  draggableView.alpha =0.5;
    UILabel *lbl =[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 40)];
    lbl.text =[NSString stringWithFormat:@"%ld",(long)index];
    [draggableView addSubview:lbl];
    [cardsView addObject:draggableView];
    return draggableView;
}


//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0) {
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
           
           
         
                newCard.backgroundColor =[UIColor grayColor];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        NSLog(@"All card count = %lu",(unsigned long)[allCards count]);
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        
        
        
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
            
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                              [self addSubview:[loadedCards objectAtIndex:i]];
            }
            
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
        [self doCardAnimation];
    }
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{          DraggableView *cardView = (DraggableView *)card;
    
    [cardView removeFromSuperview];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
      [self loadDatamakeAlpha];
    
    [self doCardAnimation];
    
}


#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    [self loadDatamakeAlpha];
    [self doCardAnimation];
    
}

-(void)loadDatamakeAlpha{
    
 
     DraggableView *view = (DraggableView *)[loadedCards objectAtIndex:0] ;
    view.alpha =1.0f;
    view.backgroundColor =[UIColor greenColor];
    [loadedCards insertObject:view atIndex:0];
    
}


static int curveValues[] = {
    UIViewAnimationOptionCurveEaseInOut,
    UIViewAnimationOptionCurveEaseIn,
    UIViewAnimationOptionCurveEaseOut,
    UIViewAnimationOptionCurveLinear };

typedef void (^Completion) (NSInteger currentIndex);


-(void) doCardAnimation {
    
    Completion aBlock;
    __block __unsafe_unretained Completion aBlock_recursive;
    aBlock_recursive = aBlock = [^(int currentValue)
                                 {
                                     if((currentValue+1) < [loadedCards count]) {
                                         
                                         [self animatingViewWithId:(currentValue+1) withCompletionBlock:aBlock_recursive ];
                                     }
                                 } copy];
    
    if( [loadedCards count]>0)
    {
        [self animatingViewWithId:0 withCompletionBlock:aBlock_recursive];
    }
}


-(void) animatingViewWithId:(NSInteger)index
        withCompletionBlock:(void (^)(NSInteger currentIndex))completion  {
    
    DraggableView *view = (DraggableView *)[loadedCards objectAtIndex:index] ;
    view.tag =index;
    
   
    
    CGRect frame = [self designFrame:index];
    CGRect beforeMove = frame;
    //beforeMove.origin.x+=10;
    beforeMove.origin.y-=10;
    
    [view createView:beforeMove];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:curveValues[3]
                     animations:^{
                         
                         view.frame = frame;
                         
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5 animations:^{
                             
                             completion(index);
                         } completion:nil];
                         
                         
                     }];
    
    
}

-(void)acceptPrayerRequest:(NSDictionary*)prayerData {
    [delegate acceptPrayerRequest:prayerData];
}

@end
