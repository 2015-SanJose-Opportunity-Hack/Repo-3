//
//  TaskWithImageTableViewCell.h
//  iCare
//
//  Created by Akshay on 10/3/15.
//  Copyright (c) 2015 akshay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskWithImageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *taskImage;

@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
