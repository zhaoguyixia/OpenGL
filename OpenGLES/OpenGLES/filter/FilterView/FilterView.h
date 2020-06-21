//
//  FilterView.h
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/10.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterView : UIView

@property (nonatomic, copy) NSString *filterName;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, assign) float vortexSub;

/// 灵魂出窍时的缩放比例
@property (nonatomic, assign) float soulScale;

@end

NS_ASSUME_NONNULL_END
