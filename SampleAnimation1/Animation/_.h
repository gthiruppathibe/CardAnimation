//
//  DraggableView.h



#import <UIKit/UIKit.h>


@protocol DraggableViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
-(void)cardTap;
-(void)acceptPrayerRequest:(NSDictionary*)prayerData;
@end

@protocol DraggableViewDelegateForGrid <NSObject>
-(void)cardPinch:(float)yValue :(UIPanGestureRecognizer*)panGesture;

@end

@interface DraggableView : UIView
@property (weak, nonatomic) IBOutlet UITextField *TestField;

@property (weak) id <DraggableViewDelegate> delegate;
@property (weak) id <DraggableViewDelegateForGrid> delegateGrid;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong)UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong)UISwipeGestureRecognizer *longPressRecognizer;
@property (nonatomic)CGPoint originalPoint;


- (id)initWithData:(NSDictionary *)dict frame:(CGRect)frame DesignViewFrame:(CGRect)designFrame;
- (void) createView:(CGRect)designFrame;
@end
