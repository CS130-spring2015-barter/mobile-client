//
//  ProfileTableCell.h
//  Bartr
//
//  Created by Andrea Kuan on 5/10/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *subtitleLabel;
@end