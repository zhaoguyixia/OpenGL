//
//  FilterTitleCell.m
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/10.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "FilterTitleCell.h"

@interface FilterTitleCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation FilterTitleCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.userInteractionEnabled = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor blackColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}
- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (isSelected) {
        self.backgroundColor = [UIColor cyanColor];
    }else{
        self.backgroundColor = [UIColor grayColor];
    }
}

@end
