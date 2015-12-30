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
#import "GameVC.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *gameTable;
@property (nonatomic, strong) NSArray *gameDatas;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GameList" ofType:@"plist"];
    self.gameDatas = [NSArray arrayWithContentsOfFile:path];
}

#pragma mark - UITableView协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gameDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseId"];
    }
    NSDictionary *dic = [self.gameDatas objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *path = [[NSBundle mainBundle] pathForResource:cell.textLabel.text ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    GameVC *game = [[GameVC alloc] init];
    game.chip.rom = data;
    [self.navigationController pushViewController:game animated:YES];
}

@end
