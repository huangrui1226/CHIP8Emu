//
//  ViewController.m
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import "ViewController.h"
#import "CHIP8.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/huangrui/Downloads/c8games/PONG"];
    CHIP8 *chip = [[CHIP8 alloc] init];
    chip.rom = data;
    for (; ; ) {
        [chip emulateCycle];
        [chip debugRender];
    }
}

@end
