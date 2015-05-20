//
//  TextFormCell.h
//  Bartr
//
//  Created by admin on 5/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CellTextFieldWidth 90.0
#define MarginBetweenControls 20.0

@interface TextFormCell : UITableViewCell {
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;

@end