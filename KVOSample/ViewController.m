//
//  ViewController.m
//  KVOSample
//
//  Created by Neil Wu on 2017/6/29.
//  Copyright © 2017年 Neil Wu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *hitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hitButton addTarget:self action:@selector(hit:) forControlEvents:UIControlEventTouchUpInside];
    [hitButton setTitle:@"攻擊" forState:UIControlStateNormal];
    [hitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [hitButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [hitButton.layer setBorderWidth:0.3];
    [hitButton setFrame:CGRectMake((self.view.bounds.size.width-100)/2, (self.view.bounds.size.height-40)/2, 100, 40)];
    [self.view addSubview:hitButton];
    
    NSArray *segmentedItem = @[@"自動補血", @"關閉"];
    UISegmentedControl *autoHP = [[UISegmentedControl alloc] initWithItems:segmentedItem];
    [autoHP setFrame:CGRectMake((self.view.bounds.size.width-150)/2, 70, 150, 40)];
    [autoHP setSelectedSegmentIndex:0];
    [autoHP addTarget:self action:@selector(changeAuto:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:autoHP];
    
    //被觀察的值一定要設成 @property
    _hp = 100;
    
    //註冊觀察者 第一個 self 代表被觀察的對象，第二個 self 是觀察者是誰，keyPath 是要觀察的值名字
    [self addObserver:self forKeyPath:@"hp" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark observer
//更動時會呼叫的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hp"]) {
        printf("hp監測中 原本hp:%d 現在hp:%d\n", [[change objectForKey:@"old"] intValue], [[change objectForKey:@"new"] intValue]);
        if (_hp < 50) {
            printf("自動喝血程式啟動\n");
            _hp = 100;
            printf("hp以恢復到100\n");
        }
    }
}

#pragma mark - Button method

- (void)hit:(id)sender
{
    int random = arc4random_uniform(20);
    if (_hp - random > 0) {
        //透過setter給值才會觸發kvo
        self.hp = _hp - random;
        printf("================= 剩餘hp:%d\n", self.hp);
    }
    else {
        //這樣給值不會觸發kvo
        _hp = 0;
        printf("================= 剩餘hp:%d 來不及喝水，你已經死惹\n", _hp);
    }
    
}

#pragma mark - Segmented method

- (void)changeAuto:(id)sender
{
    if ([sender selectedSegmentIndex] == 0) {
        
        [self addObserver:self forKeyPath:@"hp" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
    }
    else {
        
        [self removeObserver:self forKeyPath:@"hp" context:nil];
        
    }
}

@end
