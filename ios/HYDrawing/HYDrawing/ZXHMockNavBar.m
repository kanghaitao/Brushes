//
//  ZXHMockselfBar.m
//  HYDrawing
//
//  Created by macbook on 15/8/13.
//  Copyright (c) 2015年 Founder. All rights reserved.
//

#import "ZXHMockNavBar.h"
#import "Macro.h"

@implementation ZXHMockNavBar

-(instancetype)initWithLeftBtnTitle:(NSString *)leftTitle title:(NSString *)title rightBtnTitle:(NSString *)rightTitle{
    CGFloat selfW = kScreenW;
    CGFloat selfH = 64;
    CGFloat btnW = 60;
    
    if (self = [super initWithFrame:CGRectMake(0, 0, selfW, selfH)]) {
        
        if (leftTitle) {
            UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, (selfH-30)/2, btnW, 30)];
            leftBtn.backgroundColor = [UIColor whiteColor];
            leftBtn.titleLabel.font = kFontSize(14);
            [leftBtn setTitle:leftTitle forState:0];
            [leftBtn setTitleColor:UIPopoverBorderColor forState:0];
            leftBtn.layer.borderColor = UIPopoverBorderColor.CGColor;
            leftBtn.layer.cornerRadius = 4;
            leftBtn.layer.borderWidth = 2;
            _leftBtn = leftBtn;
            [self addSubview:_leftBtn];
        }
        
        if (title) {
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((selfW-200)/2, (selfH-30)/2, 200, 30)];
            titleLabel.text = title;
            titleLabel.textColor = UIPopoverBorderColor;
            titleLabel.font = kFontSize(18);
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:titleLabel];
        }
        
        if (rightTitle) {
            UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(selfW-20-btnW, (selfH-30)/2, btnW, 30)];
            rightBtn.titleLabel.font = kFontSize(14);
            [rightBtn setTitle:rightTitle forState:0];
            rightBtn.backgroundColor = UIPopoverBackgroundColor;
            [rightBtn setTitleColor:UIPopoverBorderColor forState:0];
            rightBtn.layer.borderColor = UIPopoverBorderColor.CGColor;
            rightBtn.layer.borderWidth = 2;
            rightBtn.layer.cornerRadius = 4;
            _rightBtn = rightBtn;
            [self addSubview:_rightBtn];
        }
        
        // 分割线
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, selfH-2, selfW, 2)];
        lineView.backgroundColor = UIPopoverBorderColor;
        
        self.backgroundColor = kCommenSkinColor;
        self.alpha = 0.5;
        
        [self addSubview:lineView];
    }
    
    return self;
}


@end