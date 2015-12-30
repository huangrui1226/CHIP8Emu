//
//  GameVC.h
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHIP8;

@interface GameVC : UIViewController
@property (nonatomic, strong) CHIP8 *chip;
@end
