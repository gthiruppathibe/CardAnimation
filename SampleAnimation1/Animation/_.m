//
//  DraggableView.m


#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle



#import "DraggableView.h"


@interface DraggableView ()

@property (nonatomic,strong) UILabel* cardTitle;
@property (nonatomic,strong) NSDictionary* dataSource;

@end

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate,delegateGrid;
@synthesize cardTitle =_cardTitle;
@synthesize dataSource =_dataSource;

@synthesize panGestureRecognizer,pinchGestureRecognizer,tapGestureRecognizer,longPressRecognizer;


- (id)initWithData:(NSDictionary *)dict frame:(CGRect)frame DesignViewFrame:(CGRect)designFrame{
    self = [super initWithFrame:frame];
    self = [super init];
    if (self) {
        self.dataSource = dict;
        
    }
    return self;
}

-(void)setupView
{
    self.layer.cornerRadius =6;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

-(void)handleTap
{
    [delegate cardTap];
}


float lastScale=0;
-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer*)gestureRecogniser
{
    switch (gestureRecogniser.state) {
        case UIGestureRecognizerStateBegan:{
            lastScale = [gestureRecogniser scale];
            break;
        };
        case UIGestureRecognizerStateChanged:{
            
            break;
        };
        case UIGestureRecognizerStateEnded: {
            [UIView animateWithDuration:0.6 animations:^
             {
                 self.transform=CGAffineTransformMakeScale(1.05, 1.05);
             } completion:^(BOOL finished)
             {
                 [UIView animateWithDuration:1.0 animations:^
                  {
                      self.transform=CGAffineTransformMakeScale(1.0, 1.0);
                      
                      
                  } completion:^(BOOL finished)
                  {
                      [delegateGrid cardPinch:self.frame.origin.y :panGestureRecognizer];
                      
                  }];
             }];
            
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
    
    
}

-(void)beingDraggedInGrid:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            self.center = CGPointMake(self.originalPoint.x , self.originalPoint.y + yFromCenter);
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}


//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter =0;// [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}


//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             //                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}


- (void) createView:(CGRect)designFrame {
    
    self.frame = designFrame;
    [self setupView];
    self.backgroundColor = [UIColor grayColor];
    UISwipeGestureRecognizer *recog = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipingView:)];
    recog.direction = UISwipeGestureRecognizerDirectionLeft;
  //  [self addGestureRecognizer:recog];
    
    
}


- (void) swipingView: (UITapGestureRecognizer *)recognizer{
      [UIView animateWithDuration:3.0f animations:^(void){
        CGRect endPos = self.frame;
        endPos.origin.x -= endPos.size.width; //Move it out of the view's frame to the left
        
        self.frame = endPos;
        
    } completion:^(BOOL done){
    }];
}



@end
