//
//  ViewController.m
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import "ViewController.h"
#import "CHIP8.h"
#import "GameView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GameView *gameView;
@property (nonatomic, strong) CHIP8 *chip;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/huangrui/Downloads/c8games/BLINKY"];
    self.chip = [[CHIP8 alloc] init];
    self.chip.rom = data;
    NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60 target:self selector:@selector(runlo:) userInfo:nil repeats:YES];
    [time fire];
}

- (void)runlo:(id)sender {
    [self.chip emulateCycle];
    if (self.chip.drawFlag) {
        self.gameView.Pic = [self.chip returnGfx];
        [self.gameView setNeedsDisplay];
    }
}

- (IBAction)btnDown:(UIButton *)sender {
    [self.chip keyDown:sender.tag];
    NSLog(@"%ld", sender.tag);
}

- (IBAction)btnUp:(UIButton *)sender {
    [self.chip keyUp:sender.tag];
    NSLog(@"%ld", sender.tag);
}

@end
