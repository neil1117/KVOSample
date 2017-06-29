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
    
    //隨便設個介面
    //攻擊按鈕
    UIButton *hitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hitButton addTarget:self action:@selector(hit:) forControlEvents:UIControlEventTouchUpInside];
    [hitButton setTitle:@"攻擊" forState:UIControlStateNormal];
    [hitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [hitButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [hitButton.layer setBorderWidth:0.3];
    [hitButton setFrame:CGRectMake((self.view.bounds.size.width-100)/2, (self.view.bounds.size.height-40)/2, 100, 40)];
    [self.view addSubview:hitButton];
    
    //自動補寫開關
    NSArray *segmentedItem = @[@"自動補血", @"關閉"];
    UISegmentedControl *autoHP = [[UISegmentedControl alloc] initWithItems:segmentedItem];
    [autoHP setFrame:CGRectMake((self.view.bounds.size.width-150)/2, 70, 150, 40)];
    [autoHP setSelectedSegmentIndex:0];
    [autoHP addTarget:self action:@selector(changeAuto:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:autoHP];
    
    //資訊欄
    infoTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-300)/2, hitButton.frame.origin.y+hitButton.frame.size.height+10, 300, (self.view.bounds.size.height-40)/2 - 20)];
    [infoTextView.layer setBorderWidth:0.3];
    [infoTextView.layer setBorderColor:[UIColor blackColor].CGColor];
    [infoTextView setEditable:NO];
    [self.view addSubview:infoTextView];
    
    //被觀察的值一定要設成 @property
    _hp = 100;
    
    //註冊觀察者 第一個 self 代表被觀察的對象，第二個 self 是觀察者是誰，keyPath 是要觀察的值名字
    [self addObserver:self forKeyPath:@"hp" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) inputNewString:(NSString*)newStr
{
    [infoTextView setText:[infoTextView.text stringByAppendingString:newStr]];
    [infoTextView scrollRangeToVisible:NSMakeRange(infoTextView.text.length, 1)];
}

#pragma mark observer
//更動時會呼叫的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hp"]) {
        
        [self inputNewString:[NSString stringWithFormat:@"hp監測中 原本hp:%@ 現在hp:%@\n", [change objectForKey:@"old"], [change objectForKey:@"new"]]];
        if (_hp < 50) {
            
            [self inputNewString:[NSString stringWithFormat:@"自動喝血程式啟動\n"]];
            _hp = 100;
            [self inputNewString:[NSString stringWithFormat:@"hp以恢復到100\n"]];
            
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
        [self inputNewString:[NSString stringWithFormat:@"============ 剩餘hp:%d\n", self.hp]];
    }
    else {
        //這樣給值不會觸發kvo
        _hp = 0;
        [self inputNewString:[NSString stringWithFormat:@"============ 剩餘hp:%d 來不及喝水，你已經死惹\n", self.hp]];
    }
    
}

#pragma mark - Segmented method

- (void)changeAuto:(id)sender
{
    if ([sender selectedSegmentIndex] == 0) {
        
        [self addObserver:self forKeyPath:@"hp" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
    }
    else {
        //移除kvo
        [self removeObserver:self forKeyPath:@"hp" context:nil];
        
    }
}

@end
