//
//  HYDrawingViewController.h
//  HYDrawing
//
//  Created by 李 雷川 on 15/7/16.
//  Copyright (c) 2015年 Founder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYDrawingViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>

// 图片变换属性
@property(nonatomic,retain)NSArray *imgEditInfo;

@end