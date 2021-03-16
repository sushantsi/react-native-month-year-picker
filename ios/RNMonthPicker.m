//
//  RNMonthPicker.m
//  RNMonthPicker
//
//  Created by Gustavo Paris on 22/04/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//
#import "RNMonthPicker.h"

#import <React/RCTConvert.h>
#import <React/RCTUtils.h>

#define DEFAULT_SIZE 31

@interface RNMonthPicker() <UIPickerViewDataSource, UIPickerViewDelegate>
@end

@implementation RNMonthPicker

NSCalendar *gregorian;
NSDateFormatter *df;
NSDateComponents *maxComponents;
NSDateComponents *minComponents;

NSMutableArray *years;
NSInteger selectedMonthRow;
NSInteger selectedYearRow;
int maxDaysInMonth[12] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.delegate = self;
        gregorian = [NSCalendar currentCalendar];
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMMM"];
        _value = nil;
        _minimumDate = nil;
        _maximumDate = nil;
    }
    return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (void)setLocale:(NSLocale *)useLocale {
    [df setLocale:useLocale];
}

- (void)setMode:(NSString *)mode {
    if ([mode isEqualToString:@"number"]) {
        [df setDateFormat:@"MM"];
    } else if ([mode isEqualToString:@"shortNumber"]) {
        [df setDateFormat:@"M"];
    } else if ([mode isEqualToString:@"short"]) {
        [df setDateFormat:@"MMM"];
    }
}

- (void)setValue:(nonnull NSDate *)value {
    if (value != _value) {
        NSDateComponents *selectedDateComponents = [gregorian components:(NSCalendarUnitDay|NSCalendarUnitMonth) fromDate:value];
        years = [[NSMutableArray alloc] init];
        for (int i=1; i<DEFAULT_SIZE+1; i++) {
            [years addObject:[NSNumber numberWithInt:i]];
        }
        if (!_value) {
           //[self initDays: [selectedDateComponents month]];
            selectedMonthRow = [selectedDateComponents month] - 1;
            selectedYearRow = [selectedDateComponents day] - 1;
            [self setSelectedRows: NO];
        }
        _value = value;
    }
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    _maximumDate = maximumDate;
    maxComponents = _maximumDate ? [gregorian components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:_maximumDate] : nil;
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate;
    minComponents = _minimumDate ? [gregorian components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:_minimumDate] : nil;
}

- (void)setSelectedRows:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self selectRow:selectedMonthRow inComponent:0 animated:animated];
        [self selectRow:selectedYearRow inComponent:1 animated:animated];
    });
}

#pragma mark - UIPickerViewDataSource protocol
// number of columns
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 2;
}

// number of rows
- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 1:
            return [years count];
        case 0:
            return 12;
            break;
        default:
            return 0;
    }
}

#pragma mark - UIPickerViewDelegate methods
// row titles
- (NSString *)pickerView:(nonnull UIPickerView *) pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setMonth:row + 1];
            return [NSString stringWithFormat:@"%@", [df stringFromDate:[gregorian dateFromComponents:comps]]];
        }
        case 1:
            return [NSString stringWithFormat:@"%@", years[row]];
        default:
            return nil;
    }
}

- (void)getSelectedMonthRow:(NSInteger)row {
        selectedMonthRow = row;
}

- (void)getSelectedYearRow:(NSInteger)row {
    int number = maxDaysInMonth[selectedMonthRow];
    BOOL inRange = NSLocationInRange(row+1, NSMakeRange(1, number));
    if(inRange){
        selectedYearRow = row;
    }else{
        selectedYearRow = number - 1;
    }
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(__unused NSInteger)component {
    switch (component) {
        case 0:
            [self getSelectedMonthRow:row];
            [self getSelectedYearRow:selectedYearRow];
            break;
        case 1:
            [self getSelectedYearRow:row];
//            [self getSelectedMonthRow:selectedMonthRow];
            break;
        default:
            return;
    }
    [self setSelectedRows: YES];
    if (_onChange) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setMonth:selectedMonthRow + 1];
        [comps setDay:selectedYearRow + 1];
        [comps setYear:2021];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *newDate = [calendar dateFromComponents:comps];
        _onChange(@{
                @"newDate": [NSString stringWithFormat: @"%@ %@", [NSString stringWithFormat: @"%ld", selectedMonthRow + 1],[NSString stringWithFormat: @"%ld", selectedYearRow + 1]]
        });
    }
}

@end
