//
//  CHIP8.m
//  CHIP8Emu
//
//  Created by 黄瑞 on 15/12/30.
//  Copyright © 2015年 HuangRui. All rights reserved.
//

#import "CHIP8.h"
#import "AudioController.h"

UInt8 chip8_fontset[80] =
{
    0xF0, 0x90, 0x90, 0x90, 0xF0, //0
    0x20, 0x60, 0x20, 0x20, 0x70, //1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, //2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, //3
    0x90, 0x90, 0xF0, 0x10, 0x10, //4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, //5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, //6
    0xF0, 0x10, 0x20, 0x40, 0x40, //7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, //8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, //9
    0xF0, 0x90, 0xF0, 0x90, 0x90, //A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, //B
    0xF0, 0x80, 0x80, 0x80, 0xF0, //C
    0xE0, 0x90, 0x90, 0x90, 0xE0, //D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, //E
    0xF0, 0x80, 0xF0, 0x80, 0x80  //F
};

@interface CHIP8 () {
    UInt16 pc;
    UInt16 opcode;
    UInt16 I;
    UInt16 sp;
    UInt16 stack[16];
    UInt8 gfx[64 * 32];
    UInt8 memory[4096];
    UInt8 V[16];
    UInt8 key[16];
    UInt8 delay_timer;
    UInt8 sound_timer;
}
@property (strong, nonatomic) AudioController *audioController;
@end

@implementation CHIP8

- (void)setRom:(NSData *)rom {
    _rom = rom;
    NSUInteger len = [_rom length];
    Byte *byte = (Byte*)malloc(len);
    memcpy(byte, [_rom bytes], len);
    for (NSInteger i = 0; i < _rom.length; i++) {
        memory[i + 512] = byte[i];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.audioController = [[AudioController alloc] init];
        pc = 0x0200;
        opcode = 0x0000;
        I = 0x0000;
        sp = 0x0000;
        for (NSInteger i = 0; i < 16; i++) {
            stack[i] = 0x0000;
        }
        for (NSInteger i = 0; i < 4096; i++) {
            memory[i] = 0x00;
        }
        for (NSInteger i = 0; i < 8; i++) {
            V[i] = 0x00;
        }
        for (NSInteger i = 0; i < 64 * 32; i++) {
            gfx[i] = 0x00;
        }
        for (NSInteger i = 0; i < 16; i++) {
            key[i] = 0x00;
        }
        delay_timer = 0;
        sound_timer = 0;
        for (NSInteger i = 0; i < 80; i++) {
            memory[i] = chip8_fontset[i];
        }
        self.drawFlag = true;
    }
    return self;
}

- (void)emulateCycle {
    opcode = memory[pc] << 8 | memory[pc + 1];
    switch (opcode & 0xF000) {
        case 0x0000:
            switch (opcode & 0x000F) {
                case 0x0000:
                    //0x00E0
                    //Clears the screen.
                    for (NSInteger i = 0; i < 64 * 32; i++) {
                        gfx[i] = 0x00;
                    }
                    self.drawFlag = true;
                    pc += 2;
                    break;
                case 0x000E:
                    //0x00EE
                    //Returns from a subroutine.
                    sp--;
                    pc = stack[sp];
                    pc += 2;
                    break;
                default:
                    NSLog(@"Unknow OpCode [0x0000]: 0x%X", opcode);
                    break;
            }
            break;
        case 0x1000:
            //0x1NNN
            //Jumps to address NNN.
            pc = opcode & 0x0FFF;
            break;
        case 0x2000:
            //0x2NNN
            //Calls subroutine at NNN.
            stack[sp] = pc;
            sp++;
            pc = opcode & 0x0FFF;
            break;
        case 0x3000:
            //3XNN
            //Skips the next instruction if VX equals NN.
            if (V[(opcode & 0x0F00) >> 8] == (opcode & 0x00FF)) {
                pc += 4;
            } else {
                pc += 2;
            }
            break;
        case 0x4000:
            //4XNN
            //Skips the next instruction if VX doesn't equal NN.
            if (V[(opcode & 0x0F00) >> 8] != (opcode & 0x00FF)) {
                pc += 4;
            } else {
                pc += 2;
            }
            break;
        case 0x5000:
            //5XY0
            //Skips the next instruction if VX equals VY.
            if (V[(opcode & 0x0F00) >> 8] == V[(opcode & 0x00F0) >> 4]) {
                pc += 4;
            } else {
                pc += 2;
            }
            break;
        case 0x6000:
            //6XNN
            //Sets VX to NN.
            V[(opcode & 0x0F00) >> 8] = opcode & 0x00FF;
            pc += 2;
            break;
        case 0x7000:
            //7XNN
            //Adds NN to VX.
            V[(opcode & 0x0F00) >> 8] += opcode & 0x00FF;
            pc += 2;
            break;
        case 0x8000:
            switch (opcode & 0x000F) {
                case 0x0000:
                    //8XY0
                    //Sets VX to the value of VY.
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x00F0) >> 4];
                    pc += 2;
                    break;
                case 0x0001:
                    //8XY1
                    //Sets VX to VX or VY.
                    V[(opcode & 0x0F00) >> 8] |= V[(opcode & 0x00F0) >> 4];
                    pc += 2;
                    break;
                case 0x0002:
                    //8XY2
                    //Sets VX to VX and VY.
                    V[(opcode & 0x0F00) >> 8] &= V[(opcode & 0x00F0) >> 4];
                    pc += 2;
                    break;
                case 0x0003:
                    //8XY3
                    //Sets VX to VX xor VY.
                    V[(opcode & 0x0F00) >> 8] ^= V[(opcode & 0x00F0) >> 4];
                    pc += 2;
                    break;
                case 0x0004:
                    //8XY4
                    //Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
                    if ((0xFF - V[(opcode & 0x0F00) >> 8]) < V[(opcode & 0x00F0) >> 4]) {
                        V[15] = 1;
                    } else {
                        V[15] = 0;
                    }
                    V[(opcode & 0x0F00) >> 8] += V[(opcode & 0x00F0) >> 4];
                    pc += 2;
                    break;
                case 0x0005:
                    //8XY5
                    //VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                    if (V[(opcode & 0x0F00) >> 8] > V[(opcode & 0x00F0) >> 4]) {
                        V[15] = 1;
                    } else {
                        V[15] = 0;
                    }
                    V[(opcode & 0x0F00) >> 8] -= V[(opcode & 0x00F0) >> 4];
                    pc += 2;
                    break;
                case 0x0006:
                    //8XY6
                    //Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
                    V[15] = V[(opcode & 0x0F00) >> 8] & 0x0001;
                    V[(opcode & 0x0F00) >> 8] >>= 1;
                    pc += 2;
                    break;
                case 0x0007:
                    //8XY7
                    //Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                    if (V[(opcode & 0x00F0) >> 4] > V[(opcode & 0x0F00) >> 8]) {
                        V[15] = 1;
                    } else {
                        V[15] = 0;
                    }
                    V[(opcode & 0x0F00) >> 8] = V[(opcode & 0x00F0) >> 4] - V[(opcode & 0x0F00) >> 8];
                    pc += 2;
                    break;
                case 0x000E:
                    //8XYE
                    //Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
                    V[15] = V[(opcode & 0x0F00) >> 8] >> 7;
                    V[(opcode & 0x0F00) >> 8] <<= 1;
                    pc += 2;
                    break;
                default:
                    NSLog(@"Unknown opcode [0x8000]: 0x%X\n", opcode);
                    break;
            }
            break;
        case 0x9000:
            //9XY0
            //Skips the next instruction if VX doesn't equal VY.
            if (V[(opcode & 0x0F00) >> 8] != V[(opcode & 0x00F0) >> 4]) {
                pc += 4;
            } else {
                pc += 2;
            }
            break;
        case 0xA000:
            //ANNN
            //Sets I to the address NNN.
            I = opcode & 0x0FFF;
            pc += 2;
            break;
        case 0xB000:
            //BNNN
            //Jumps to the address NNN plus V0.
            pc = (opcode & 0x0FFF) + V[0];
        case 0xC000: {
            //CXNN
            //Sets VX to the result of a bitwise and operation on a random number and NN.
            UInt8 ran = arc4random() % 256;
            V[(opcode & 0x0F00) >> 8] = ran & (opcode & 0x00FF);
            pc += 2;
        }
            break;
        case 0xD000: {
            //DXYN
            //Sprites stored in memory at location in index register (I), 8bits wide. Wraps around the screen. If when drawn, clears a pixel, register VF is set to 1 otherwise it is zero. All drawing is XOR drawing (i.e. it toggles the screen pixels). Sprites are drawn starting at position VX, VY. N is the number of 8bit rows that need to be drawn. If N is greater than 1, second line continues at position VX, VY+1, and so on.
            UInt8 x = V[(opcode & 0x0F00) >> 8];
            UInt8 y = V[(opcode & 0x00F0) >> 4];//取得x,y(横纵坐标)
            UInt8 height = opcode & 0x000F;//取得图案的高度
            UInt8 pixel;
            
            V[15] = 0;//初始化VF为0
            for (UInt8 yline = 0; yline < height; yline++)//对于每一行
            {
                pixel = memory[I + yline];//取得内存I处的值，pixel中包含了一行的8个像素
                for(UInt8 xline = 0; xline < 8; xline++)//对于1行中的8个像素
                {
                    if((pixel & (0x80 >> xline)) != 0)//检查当前像素是否为1
                    {
                        if(gfx[(x + xline + ((y + yline) * 64))] == 1)//如果显示缓存gfx[]里该像素也为1，则发生了碰撞(64是CHIP8的显示宽度)
                        {
                            V[15] = 1;//设置VF为1
                        }
                        gfx[x + xline + ((y + yline) * 64)] ^= 1;//gfx中用1个byte来表示1个像素，其值为1或0。这里异或相当于取反
                    }
                }
            }
            self.drawFlag = true;//绘画标志置为1
            pc += 2;
        }
            break;
        case 0xE000:
            switch (opcode & 0x00FF) {
                case 0x009E:
                    //EX9E
                    //Skips the next instruction if the key stored in VX is pressed.
                    if (key[V[(opcode & 0x0F00) >> 8]] != 0) {
                        pc += 4;
                    } else {
                        pc += 2;
                    }
                    break;
                case 0x00A1:
                    //EXA1
                    //Skips the next instruction if the key stored in VX isn't pressed.
                    if (key[V[(opcode & 0x0F00) >> 8]] == 0) {
                        pc += 4;
                    } else {
                        pc += 2;
                    }
                    break;
                default:
                    NSLog(@"Unknown opcode [0xE000]: 0x%X\n", opcode);
                    break;
            }
            break;
        case 0xF000:
            switch (opcode & 0x00FF) {
                case 0x0007:
                    //FX07
                    //Sets VX to the value of the delay timer.
                    V[(opcode & 0x0F00) >> 8] = delay_timer;
                    pc += 2;
                    break;
                case 0x000A: {
                    //FX0A
                    //A key press is awaited, and then stored in VX.
                    BOOL keyPres = false;
                    for (UInt8 i = 0; i < 16; i++) {
                        if (key[i] != 0) {
                            keyPres = true;
                            V[(opcode & 0x0F00) >> 8] = i;
                        }
                    }
                    if (!keyPres) {
                        return;
                    }
                    pc += 2;
                }
                    break;
                case 0x0015:
                    //FX15
                    //Sets the delay timer to VX.
                    delay_timer = V[(opcode & 0x0F00) >> 8];
                    pc += 2;
                    break;
                case 0x0018:
                    //FX18
                    //Sets the sound timer to VX.
                    sound_timer = V[(opcode & 0x0F00) >> 8];
                    pc += 2;
                    break;
                case 0x001E:
                    //FX1E
                    //Adds VX to I.
                    if (I + V[(opcode & 0x0F00) >> 8] > 0x0FFF) {
                        V[15] = 1;
                    } else {
                        V[15] = 0;
                    }
                    I += V[(opcode & 0x0F00) >> 8];
                    pc += 2;
                    break;
                case 0x0029:
                    //FX29
                    //Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
                    I = V[(opcode & 0x0F00) >> 8] * 0x5;
                    pc += 2;
                    break;
                case 0x0033:
                    //FX33
                    //Stores the Binary-coded decimal representation of VX, with the most significant of three digits at the address in I, the middle digit at I plus 1, and the least significant digit at I plus 2. (In other words, take the decimal representation of VX, place the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2.)
                    memory[I] = V[(opcode & 0x0F00) >> 8] / 100 % 10;
                    memory[I + 1] = V[(opcode & 0x0F00) >> 8] / 10 % 10;
                    memory[I + 2] = V[(opcode & 0x0F00) >> 8] / 1 % 10;
                    pc += 2;
                    break;
                case 0x0055:
                    //FX55
                    //Stores V0 to VX in memory starting at address I.
                    for (UInt8 i = 0; i <= ((opcode & 0x0F00) >> 8); ++i) {
                        memory[I + i] = V[i];
                    }
                    //在原解释器中，当这个操作完成的时候, I = I + X + 1.
                    I += ((opcode & 0x0F00) >> 8) + 1;
                    pc += 2;
                    break;
                case 0x0065:
                    //FX65
                    //Fills V0 to VX with values from memory starting at address I.
                    for (UInt8 i = 0; i <= ((opcode & 0x0F00) >> 8); ++i) {
                        V[i] = memory[I + i];
                    }
                    //在原解释器中，当这个操作完成的时候, I = I + X + 1.
                    I += ((opcode & 0x0F00) >> 8) + 1;
                    pc += 2;
                    break;
                default:
                    NSLog(@"Unknown opcode [0xF000]: 0x%X\n", opcode);
                    break;
            }
            break;
        default:
            NSLog(@"Unknown opcode: 0x%X\n", opcode);
            break;
    }
    if (delay_timer > 0) {
        delay_timer--;
        if (delay_timer == 0) {
        }
    }
    if (sound_timer > 0) {
        sound_timer--;
        if (sound_timer == 0) {
            [self.audioController playSystemSound];
        }
    }
}

- (void)debugRender {
    //用于debug，用控制台方式输出显存中的值
    for(int y = 0; y < 32; ++y) {
        for(int x = 0; x < 64; ++x) {
            if(gfx[(y * 64) + x] == 0)
                printf(" ");
            else
                printf("0");
        }
        printf("\n");
    }
    printf("\n");
}

- (void)keyDown:(NSInteger)tag {
    key[tag] = 1;
}

- (void)keyUp:(NSInteger)tag {
    key[tag] = 0;
}

- (NSMutableArray *)returnGfx {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i = 0; i < 2048; i++) {
        NSNumber *num = [NSNumber numberWithUnsignedChar:gfx[i]];
        [arr addObject:num];
    }
    return arr;
}

@end
