//
//  ViewController.m
//  CustomDatePicker
//
//  Created by A on 2020/1/16.
//  Copyright © 2020 A. All rights reserved.
//

#import "ViewController.h"
#import "CustomDatePickerViewController.h"
#import <NSDate+DateTools.h>

#define jkHexColor(hexString)     [UIColor colorWithHexString:hexString]

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentLabel.text = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
}

- (IBAction)didClickChooseDatePickerButton:(UIButton *)sender {
    CustomDatePickerViewController *picker = [[CustomDatePickerViewController alloc]init];
    picker.cancelTextColor = [UIColor redColor];
    picker.datePickerMode = TTDatePickerModeYearAndDate;
    picker.sureTextColor = [UIColor blueColor];
    picker.clickDismiss = YES;
    
    // 最小显示时间 注意是+1的
    picker.startYear = 2016;
    ///获取当前的年份
    NSInteger currentYear = [[NSDate date] year];
    ///系统时间在2019年之前, 默认最大时间是2037年
    if (currentYear < 2019) currentYear = 2037;
    // 最大显示时间
    picker.endYear = currentYear;
    // 当前选中时间
    picker.date = [NSDate date];
    __weak typeof (self) weakSelf = self;
    picker.selectedDate = ^(NSDateComponents *components) {
        NSString *str = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)components.year,(long)components.month,(long)components.day];
        NSLog(@"%@",str);
        weakSelf.contentLabel.text = str;
    };
    // 可以处理 ios13布局
    [self presentViewController:picker animated:YES completion:nil];
}

@end
