//
//  CustomDatePickerViewController.m
//  CustomDatePicker
//
//  Created by A on 2020/1/16.
//  Copyright © 2020 A. All rights reserved.
//

#import "CustomDatePickerViewController.h"
#import <NSDate+DateTools.h>

typedef struct {
    NSInteger year;
    NSInteger month;
    NSInteger day;
}TTPickerDate;

//MARK:NSDate 转 TTPickerDate
TTPickerDate transformFromDate(NSDate *date){
    TTPickerDate lysDate;
    NSDateComponents *component = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    lysDate.year        = [component year];
    lysDate.month       = [component month];
    lysDate.day         = [component day];
    return lysDate;
}
//MARK:TTPickerDate 转 NSDate
NSDate * transformFromComponents(TTPickerDate date){
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    [components setYear:date.year];
    [components setMonth:date.month];
    [components setDay:date.day];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}
//MARK:修改TTPickerDate中year
TTPickerDate updateYear(TTPickerDate date, NSInteger year){
    TTPickerDate tempDate = date;
    tempDate.year = year;
    return tempDate;
}

//MARK:修改TTPickerDate中month
TTPickerDate updateMonth(TTPickerDate date, NSInteger month){
    TTPickerDate tempDate = date;
    tempDate.month = month;
    return tempDate;
}

//MARK:修改TTPickerDate中day
TTPickerDate updateDay(TTPickerDate date, NSInteger day){
    TTPickerDate tempDate = date;
    tempDate.day = day;
    return tempDate;
}
//MARK:判断是否是闰年
BOOL judgeLeapYear(TTPickerDate date){
    if (date.year % 100 == 0) {
        if (date.year % 400 == 0) {return YES;} else {return NO;}
    } else {
        if (date.year % 4 == 0) {return YES;} else {return NO;}
    }
}
//MARK:判断月类型
BOOL judgeLongMonth(TTPickerDate date){
    if ([@[@1,@3,@5,@7,@8,@10,@12] containsObject:@(date.month)]) {
        return YES;
    }
    if ([@[@4,@6,@9,@11] containsObject:@(date.month)]) {
        return NO;
    }
    return NO;  /// February
}

typedef NS_ENUM(NSUInteger, TTMonthType) {
    TTMonthTypeGeneralLongMonth,                     // 31
    TTMonthTypeGeneralShortMonth,                    // 30
    TTMonthTypeLeapYearLongMonth,                    // 29
    TTMonthTypeLeapYearShortMonth                    // 28
};
TTMonthType judgeMonthType(TTPickerDate date)
{
    if (judgeLongMonth(date)) {
        return TTMonthTypeGeneralLongMonth;
    } else {
        if (date.month != 2) {
            return TTMonthTypeGeneralShortMonth;
        } else {
            if (judgeLeapYear(date)) {
                return TTMonthTypeLeapYearLongMonth;
            } else {
                return TTMonthTypeLeapYearShortMonth;
            }
        }
    }
}


@implementation TTDatePickerToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:239.0/255.0
                                               green:239.0/255.0
                                                blue:244.0/255.0
                                               alpha:1.0];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.sureBtn];
    }
    return self;
}

- (void)cancelAction{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}
- (void)sureAction{
    if (self.sureBlock) {
        self.sureBlock();
    }
}
- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(10, 0, 50, self.frame.size.height);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame = CGRectMake(self.frame.size.width - 60, 0, 50, self.frame.size.height);
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}
@end


@interface CustomDatePickerViewController ()<
UIPickerViewDelegate,
UIPickerViewDataSource
>
// pickerView
@property (strong, nonatomic) UIPickerView *pickerView;
// 时间
@property (assign, nonatomic) TTPickerDate currentDate;
// toolBar
@property (strong, nonatomic) TTDatePickerToolBar *datePickerToolBar;
// 当前月份天数
@property (assign, nonatomic) NSInteger dayNum;
// 背景
@property (strong, nonatomic) UIView *backView;

@end

@implementation CustomDatePickerViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.startYear   = 1900;
        self.endYear     = 2099;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}
- (void)setupViews{
    [self.view addSubview:self.backView];
    
    if (self.clickDismiss) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
        [self.backView addGestureRecognizer:tap];
    }
    
    // ToolBar
    __weak typeof(self) weakSelf = self;
    self.datePickerToolBar = [[TTDatePickerToolBar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 260, self.view.frame.size.width, 44)];
    self.datePickerToolBar.cancelBlock = ^{
        [weakSelf dismissView];
    };
    self.datePickerToolBar.sureBlock = ^{
        if (weakSelf.selectedDate) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:transformFromComponents(weakSelf.currentDate)];
            weakSelf.selectedDate(components);
            [weakSelf dismissView];
        }
    };
    [self.backView addSubview:self.datePickerToolBar];
    
    // UIPickerView
    self.pickerView  = [[UIPickerView alloc]init];
    self.pickerView.frame = CGRectMake(0,  self.view.frame.size.height- 216, self.view.frame.size.width, 216);
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.backView addSubview:self.pickerView];
    
    self.currentDate = transformFromDate(self.date);
    [self selectDate:self.currentDate];
    
    
    
    if (self.cancelTextColor) {
        [self.datePickerToolBar.cancelBtn setTitleColor:self.cancelTextColor forState:UIControlStateNormal];
    }
    if (self.sureTextColor) {
        [self.datePickerToolBar.sureBtn setTitleColor:self.sureTextColor forState:UIControlStateNormal];
    }
    if (self.cancelText && self.cancelText.length > 0) {
        [self.datePickerToolBar.cancelBtn setTitle:self.cancelText forState:UIControlStateNormal];
        
    }
    if (self.sureText && self.sureText.length > 0) {
        [self.datePickerToolBar.sureBtn setTitle:self.sureText forState:UIControlStateNormal];
    }
    if (self.toolBarFont) {
        [self.datePickerToolBar.cancelBtn.titleLabel setFont:self.toolBarFont];
        [self.datePickerToolBar.sureBtn.titleLabel setFont:self.toolBarFont];
    }
}

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectDate:(TTPickerDate)date{
    
    NSInteger yearIndex    = date.year-self.startYear-1;
    NSInteger monthIndex   = date.month-1;
    NSInteger dayIndex     = date.day-1;
    
    if (self.datePickerMode == TTDatePickerModeYearAndMonth) {
        [self.pickerView selectRow:yearIndex inComponent:0 animated:YES];
        [self.pickerView selectRow:monthIndex inComponent:1 animated:YES];
    }
    
    if (self.datePickerMode == TTDatePickerModeYearAndDate) {
        [self judgeMonthNumAndRefresh:2];
        [self.pickerView selectRow:yearIndex inComponent:0 animated:YES];
        [self.pickerView selectRow:monthIndex inComponent:1 animated:YES];
        [self.pickerView selectRow:dayIndex inComponent:2 animated:YES];
    }
}

// 判断当前月份天数并刷新
- (void)judgeMonthNumAndRefresh:(NSInteger)index{
    TTMonthType monthType = judgeMonthType(self.currentDate);
    switch (monthType) {
        case TTMonthTypeGeneralLongMonth:
            self.dayNum = 31;
            break;
        case TTMonthTypeGeneralShortMonth:
            self.dayNum = 30;
            break;
        case TTMonthTypeLeapYearLongMonth:
            self.dayNum = 29;
            break;
        case TTMonthTypeLeapYearShortMonth:
            self.dayNum = 28;
            break;
        default:
            self.dayNum = 31;
            break;
    }
    [self.pickerView reloadComponent:index];
}
//MARK:  pickerView 数据源及代理方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (self.datePickerMode == TTDatePickerModeYearAndMonth) {
        return 2;
    }
    
    if (self.datePickerMode == TTDatePickerModeYearAndDate) {
        return 3;
    }
    
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return self.endYear - self.startYear;
    }
    if (component == 1) {
        return 12;
    }
    if (component == 2) {
        return self.dayNum;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = nil;
    if ([view isKindOfClass:[UILabel class]]) {
        label = (UILabel *)view;
    }
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    UIColor *textColor = self.ableColor ? self.ableColor : [UIColor blackColor];
    if (component == 0) {
        if (self.minimumDate && row + 1 < self.minimumDate.year - self.startYear) {
            textColor = self.disableColor ? self.disableColor : [UIColor grayColor];
        }
        if (self.maximumDate && row + 1 > self.maximumDate.year - self.startYear) {
            textColor = self.disableColor ? self.disableColor : [UIColor grayColor];
        }
        if (self.minimumDate && self.maximumDate && self.minimumDate.year == self.maximumDate.year) {
            if (row + 1 == self.minimumDate.year - self.startYear) {
                textColor = self.ableColor ? self.ableColor : [UIColor blackColor];
            }
        }
    }
    
    if (component == 1) {
        NSInteger yearRow = [pickerView selectedRowInComponent:0];
        if (self.minimumDate &&
            yearRow + 1 == self.minimumDate.year - self.startYear &&
            row + 1 < self.minimumDate.month) {
            textColor = self.disableColor ? self.disableColor : [UIColor grayColor];
        }
        if (self.maximumDate &&
            yearRow + 1 == self.maximumDate.year - self.startYear &&
            row + 1 > self.maximumDate.month) {
            textColor = self.disableColor ? self.disableColor : [UIColor grayColor];
        }
        if (self.minimumDate &&
            self.maximumDate &&
            self.minimumDate.year == self.maximumDate.year &&
            self.minimumDate.month == self.maximumDate.month) {
            if (row + 1 == self.minimumDate.month) {
                textColor = self.ableColor ? self.ableColor : [UIColor blackColor];
            }
        }
    }
    
    if (component == 2) {
        NSInteger yearRow  = [pickerView selectedRowInComponent:0];
        NSInteger monthRow = [pickerView selectedRowInComponent:1];
        if (self.minimumDate &&
            yearRow + 1 == self.minimumDate.year - self.startYear &&
            monthRow + 1 == self.minimumDate.month &&
            row + 1 < self.minimumDate.day) {
            textColor = self.disableColor ? self.disableColor : [UIColor grayColor];
        }
        if (self.maximumDate &&
            yearRow + 1 == self.maximumDate.year - self.startYear &&
            monthRow + 1 == self.maximumDate.month &&
            row + 1 >  self.maximumDate.day) {
            textColor = self.disableColor ? self.disableColor : [UIColor grayColor];
        }
        if (self.minimumDate &&
            self.maximumDate &&
            self.minimumDate.year == self.maximumDate.year &&
            self.minimumDate.month == self.maximumDate.month &&
            self.minimumDate.day == self.maximumDate.day) {
            if (row + 1 == self.minimumDate.day) {
                textColor = self.ableColor ? self.ableColor : [UIColor blackColor];
            }
        }
    }
    
    label.textColor = textColor;
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return [NSString stringWithFormat:@"%ld年",(long)self.startYear + row + 1];
    }
    if (component == 1) {
        return [NSString stringWithFormat:@"%ld月",row + 1];
    }
    if (component == 2) {
        return [NSString stringWithFormat:@"%ld日",row + 1];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        self.currentDate = updateYear(self.currentDate, self.startYear + row + 1);
    }
    if (component == 1) {
        self.currentDate = updateMonth(self.currentDate, row + 1);
    }
    if (component == 2) {
        self.currentDate = updateDay(self.currentDate, row + 1);
    }
    
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
    
    // 刷新月份天数
    if (self.datePickerMode == TTDatePickerModeYearAndDate && (component == 0 || component == 1)) {
        [self judgeMonthNumAndRefresh:2];
    }
    
    NSDate *selectDate = transformFromComponents(self.currentDate);
    
    if (self.minimumDate) {
        NSComparisonResult miniResult = [[NSCalendar currentCalendar] compareDate:self.minimumDate toDate:selectDate toUnitGranularity:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay];
        if (miniResult == NSOrderedDescending) {
            self.currentDate = transformFromDate(self.minimumDate);
            [self selectDate:self.currentDate];
        }
    }
    
    if (self.maximumDate) {
        NSComparisonResult maxResult = [[NSCalendar currentCalendar] compareDate:self.maximumDate toDate:selectDate toUnitGranularity:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay];
        if (maxResult == NSOrderedAscending) {
            self.currentDate = transformFromDate(self.maximumDate);
            [self selectDate:self.currentDate];
        }
    }
}

//MARK:懒加载
- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:self.view.bounds];
    }
    return _backView;
}
@end
