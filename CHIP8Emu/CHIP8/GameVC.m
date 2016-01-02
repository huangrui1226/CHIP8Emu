//
//  GameVC.m
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import "GameVC.h"
#import "CHIP8.h"
#import "GameView.h"

@interface GameVC ()
@property (weak, nonatomic) IBOutlet GameView *gameView;
@property (nonatomic, strong) NSTimer *time;
@end

@implementation GameVC

- (CHIP8 *)chip {
    if (!_chip) {
        _chip = [[CHIP8 alloc] init];
    }
    return _chip;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.time invalidate];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.time = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60 target:self selector:@selector(runlo:) userInfo:nil repeats:YES];
    [self.time fire];
}

- (void)runlo:(id)sender {
    [self.chip emulateCycle];
    if (self.chip.drawFlag) {
        self.chip.drawFlag = NO;
        self.gameView.Pic = [self.chip returnGfx];
        [self.gameView setNeedsDisplay];
    }
}

- (IBAction)btnDown:(UIButton *)sender {
    NSLog(@"%ld", sender.tag);
    [self.chip keyDown:sender.tag];
}

- (IBAction)btnUp:(UIButton *)sender {
    NSLog(@"%ld", sender.tag);
    [self.chip keyUp:sender.tag];
}

@end
