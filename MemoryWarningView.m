//
//  MemoryWarningView.m
//  InnAppurchaseSample
//
//  Created by Sudhir Kumar on 15/10/15.
//  Copyright © 2015 Sudhir Kumar. All rights reserved.
//


#ifdef DEBUG

#import "MemoryWarningView.h"

@interface MemoryWarningView() {
@private
    float oldX, oldY;
    BOOL dragging;
}

@property(nonatomic,weak)UILabel *lblValue;
@property(nonatomic,weak)UIButton *btnStart;

@property(nonatomic,weak)UISlider *slider;
@end



static MemoryWarningView *_memoryWarningView = nil;


@implementation MemoryWarningView


+ (id)init {
    if (!_memoryWarningView)
        _memoryWarningView = [[MemoryWarningView alloc] initWithFrame:CGRectMake(0, 30, 100, 90)];
       return _memoryWarningView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setClipsToBounds:YES];
        [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(bringViewTofront) userInfo:nil repeats:YES];
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, CGRectGetHeight(frame), 44)];
        [slider setMaximumValue:10];
        [slider setMinimumValue:0.1];
        [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];
        self.slider= slider;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(2, 2, 44, 44);
        [btn setTitle:@"Fire" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [btn addTarget:self action:@selector(fireMemoryWarning) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor yellowColor]];
        [btn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [btn.layer setBorderWidth:2.0];
        [btn.layer setCornerRadius:5.0];
        self.btnStart = btn;
        
        UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureFires:)];
        [longPressGesture setMinimumPressDuration:0.3];
        [self.btnStart addGestureRecognizer:longPressGesture];
        
        UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOccurs:)];
        [self addGestureRecognizer:panGesture];
        
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.btnStart.frame), 0,self.frame.size.width - self.btnStart.frame.size.width, self.btnStart.frame.size.height)];
        text.text = @"0 Sec";
        text.textColor = [UIColor whiteColor];
        text.numberOfLines = 3;
        
        text.textAlignment = UITextAlignmentCenter;
        text.backgroundColor = [UIColor clearColor];
        text.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:text];
        
        self.lblValue =text;
      
    }
    return self;
}

-(void)panGestureOccurs:(UIPanGestureRecognizer *)pan
{
    CGPoint point= [pan locationInView:self.superview];
    
    CGPoint previous = self.center;
    self.center  = point;
    point = self.center;
    if (point.x >= self.frame.size.width/2.0 && (point.x <= (self.superview.frame.size.width - (self.frame.size.width/2.0))) && (point.y <=(self.superview.frame.size.height - (self.frame.size.height / 2.0))) && (point.y>=self.frame.size.height/2.0)) {
    }else{
        self.center = previous;
    }
}
-(void)longPressGestureFires:(UILongPressGestureRecognizer *)gesture
{
   if (gesture.state == UIGestureRecognizerStateBegan)
   {
   [UIView animateWithDuration:.2 animations:^{
       self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.slider.frame.size.width, CGRectGetMaxY(self.slider.frame));
   }];
   }
}

-(void)bringViewTofront
{
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
}

-(void)sliderValueChange:(UISlider *)slider
{
    self.lblValue.text=[NSString stringWithFormat:@"%.2f sec",slider.value];
}

- (void)fireMemoryWarning {
    
    SEL memoryWarningSel = @selector(_performMemoryWarning);
    if ([[UIApplication sharedApplication] respondsToSelector:memoryWarningSel]) {
        [self.btnStart setBackgroundColor:[UIColor redColor]];
        [self.btnStart setTitle:@"Firing" forState:UIControlStateNormal];
        [self.btnStart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [UIView animateWithDuration:self.slider.value animations:^{
            [self.btnStart setBackgroundColor:[UIColor greenColor]];
            
        }];
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CGRectGetMaxX(self.btnStart.frame) + self.btnStart.frame.origin.x, CGRectGetMaxY(self.btnStart.frame)+self.btnStart.frame.origin.y);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.slider.value * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.btnStart setTitle:@"Fire" forState:UIControlStateNormal];
            [self.btnStart setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [[UIApplication sharedApplication] performSelector:memoryWarningSel];
        });
    }else {
        NSLog(@"Whoops UIApplication no loger responds to -_performMemoryWarning");
    }    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.superview];
    
    if (CGRectContainsPoint(self.superview.frame, touchLocation)) {
        
        dragging = YES;
        oldX = touchLocation.x;
        oldY = touchLocation.y;
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.superview];
    
    if (dragging) {
        
        CGRect frame = self.frame;
        frame.origin.x = self.frame.origin.x + touchLocation.x - oldX;
        frame.origin.y =  self.frame.origin.y + touchLocation.y - oldY;
        self.frame = frame;
    }
    
    oldX = touchLocation.x;
    oldY = touchLocation.y;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    dragging = NO;
}



@end

#endif

