//
//  CHIP8.h
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHIP8 : NSObject
{
    UInt8 gfx[64 * 32];
}
@property (nonatomic, strong) NSData *rom;
//@property (nonatomic, strong) NSArray *gfx;
@property (nonatomic, assign) Boolean drawFlag;
- (void)emulateCycle;
- (void)debugRender;
@end
