//
//  AudioController.h
//  ATBasicSounds
//
//  Created by Audrey M Tam on 22/03/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioController : NSObject

- (instancetype)init;
- (void)tryPlayMusic;
- (void)playSystemSound;

@end
