//
//  DraggableViewBackground.h

#import <UIKit/UIKit.h>
#import "DraggableView.h"

@protocol DraggableViewBackgroundDelegate <NSObject>

-(void)draggableTableCall;
-(void)pushPrayerDetailVC;
-(void)acceptPrayerRequest:(NSDictionary*)prayerData;
-(void)showDetailView;

@end
@interface DraggableViewBackground : UIView <DraggableViewDelegate,DraggableViewDelegateForGrid>

//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;

@property (retain,nonatomic)NSArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards

@property(weak) id<DraggableViewBackgroundDelegate> delegate;

@end
