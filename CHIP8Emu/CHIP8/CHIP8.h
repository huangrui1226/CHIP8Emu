//
//  CHIP8.h
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CHIP8 : NSObject
@property (nonatomic, strong) NSData *rom;
@property (nonatomic, assign) Boolean drawFlag;
- (void)emulateCycle;
- (void)debugRender;
- (NSMutableArray *)returnGfx;
- (void)keyDown:(NSInteger)tag;
- (void)keyUp:(NSInteger)tag;
@end
