//
//  CustomDatePickerViewController.h
//  CustomDatePicker
//
//  Created by A on 2020/1/16.
//  Copyright © 2020 A. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义类型
typedef NS_ENUM(NSInteger, TTDatePickerMode) {
    TTDatePickerModeYearAndMonth,      // yyyy-MM
    TTDatePickerModeYearAndDate        // yyyy-MM-dd
};

NS_ASSUME_NONNULL_BEGIN

@interface TTDatePickerToolBar : UIView

// 取消按钮
@property (strong, nonatomic) UIButton * cancelBtn;
// 确认按钮
@property (strong, nonatomic) UIButton * sureBtn;
// 取消
@property (copy, nonatomic) void(^cancelBlock)(void);
// 确认
@property (copy, nonatomic) void(^sureBlock)(void);

@end

@interface CustomDatePickerViewController : UIViewController

@property (assign, nonatomic) TTDatePickerMode datePickerMode;
// 当前选中的时间
@property (strong, nonatomic) NSDate *date;
// 最小可选择时间
@property (strong, nonatomic) NSDate *minimumDate;
// 最大可选择时间
@property (strong, nonatomic) NSDate *maximumDate;
// 开始年份，默认1901（开始年份不包含 startYear）
@property (assign, nonatomic) NSInteger startYear;
// 结束年份，默认2099（结束年份包含 endYear）
@property (assign, nonatomic) NSInteger endYear;
// 点击蒙版是否关闭
@property (assign, nonatomic) BOOL clickDismiss;
// ToolBar取消文字颜色
@property (strong, nonatomic) UIColor *cancelTextColor;
// ToolBar确认字体颜色
@property (strong, nonatomic) UIColor *sureTextColor;
// 超出最大或最小区间后文字颜色
@property (strong, nonatomic) UIColor *disableColor;
// 安全区内文字颜色
@property (strong, nonatomic) UIColor *ableColor;
// ToolBar 取消文案
@property (copy, nonatomic) NSString *cancelText;
// ToolBar 确认文案
@property (copy, nonatomic) NSString *sureText;
// ToolBar 文案字号
@property (strong, nonatomic) UIFont *toolBarFont;
// 选中时间回调  yyyyMM/yyyyMMdd
@property (copy, nonatomic) void(^selectedDate)(NSDateComponents *components);

@end

NS_ASSUME_NONNULL_END
