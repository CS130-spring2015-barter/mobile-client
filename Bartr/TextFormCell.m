//
//  TextFormCell.m
//  Bartr
//
//  Created by admin on 5/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "TextFormCell.h"

@implementation TextFormCell

@synthesize textField;
-(void) awakeFromNib
{
    [super awakeFromNib];
    textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.clearsOnBeginEditing = NO;
    textField.textAlignment = UITextAlignmentRight;
    textField.returnKeyType = UIReturnKeyDone;
    [self.contentView addSubview:textField];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Adding the text field
        textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.clearsOnBeginEditing = NO;
        textField.textAlignment = UITextAlignmentRight;
        textField.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:textField];
    }
    return self;
}

#pragma mark -
#pragma mark Laying out subviews

- (void)layoutSubviews {
    CGRect rect = CGRectMake(self.contentView.bounds.size.width - 5.0,
                             12.0,
                             -CellTextFieldWidth,
                             25.0);
    [textField setFrame:rect];
    CGRect rect2 = CGRectMake(MarginBetweenControls,
                              12.0,
                              self.contentView.bounds.size.width - CellTextFieldWidth - MarginBetweenControls,
                              25.0);
    UILabel *theTextLabel = (UILabel *)[self textLabel];
    [theTextLabel setFrame:rect2];
}
@end
