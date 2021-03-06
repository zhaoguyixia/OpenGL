//
//  FilterTitleCell.h
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/10.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterTitleCell : UICollectionViewCell
@property (nonatomic, assign) BOOL isSelected;
- (void)setTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
