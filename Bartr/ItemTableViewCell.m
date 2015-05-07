//
//  ItemTableViewCell.m
//  Bartr
//
//  Created by admin on 5/6/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "ItemTableViewCell.h"

@implementation ItemTableViewCell
@synthesize textLabel;
@synthesize imageView;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
