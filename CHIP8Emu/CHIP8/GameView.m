//
//  GameView.m
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import "GameView.h"

#define cellW self.bounds.size.width / 64
#define cellH self.bounds.size.height / 32

@implementation GameView

- (void)drawRect:(CGRect)rect {
    for (NSInteger i = 0; i < 32; i++) {
        for (NSInteger j = 0; j < 64; j++) {
            NSNumber *num = [self.Pic objectAtIndex:(i * 64 + j)];
            if (num.unsignedCharValue != 0) {
                UIBezierPath *bezi = [UIBezierPath bezierPath];
                [bezi moveToPoint:CGPointMake(j * cellW, i * cellH)];
                [bezi addLineToPoint:CGPointMake((j+1) * cellW, i * cellH)];
                [bezi addLineToPoint:CGPointMake((j+1) * cellW, (i+1) * cellH)];
                [bezi addLineToPoint:CGPointMake(j * cellW, (i+1) * cellH)];
                [bezi closePath];
                [bezi fill];
            }
        }
    }
}

@end
