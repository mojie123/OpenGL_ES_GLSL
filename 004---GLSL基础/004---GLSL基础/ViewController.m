//
//  ViewController.m
//  004---GLSL基础
//
//  Created by 小siri on 2020/5/5.
//  Copyright © 2020 小siri. All rights reserved.
//

#import "ViewController.h"
#import "CCView.h" 
@interface ViewController ()


@property(nonnull,strong)CCView *myView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor grayColor];
  
    self.myView = [[CCView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.myView]; 
    // Do any additional setup after loading the view.
}


@end
