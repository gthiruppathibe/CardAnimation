//
//  ViewController.m
//  SampleAnimation1
//
//  Created by Sandeep Sachan on 26/03/15.
//  Copyright (c) 2015 Sandeep Sachan. All rights reserved.
//

#import "ViewController.h"
#import "DraggableViewBackground.h"
@interface ViewController ()<DraggableViewBackgroundDelegate,UIGestureRecognizerDelegate>{
    DraggableViewBackground *draggableBackground;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    draggableBackground.delegate=self;
    [self.view addSubview:draggableBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
