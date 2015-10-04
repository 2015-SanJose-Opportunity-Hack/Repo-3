//
//  ViewController.m
//  iCare
//
//  Created by Akshay on 10/3/15.
//  Copyright (c) 2015 akshay. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "TaskWithImageTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (strong, nonatomic) NSArray *tasks;
@property (strong, nonatomic) NSString *status;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskTableView.dataSource = self;
    self.taskTableView.delegate = self;
    
//    [self.taskTableView registerClass:[TaskWithImageTableViewCell class] forCellReuseIdentifier:@"taskImageCellIdentifier"];
    
    self.tasks = [[NSArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"task"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){

        PFObject *obj = (PFObject *)objects[0];
        PFFile *file = (PFFile *)obj[@"resource"];
        NSLog(@"objects %@",file.url);
        self.tasks = objects;
        [self.taskTableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tasks.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *taskImageCellIdentifier = @"taskImageCellIdentifier";

    TaskWithImageTableViewCell *cell = (TaskWithImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:taskImageCellIdentifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TaskWithImageTableViewCell" owner:nil options:nil] objectAtIndex: 0];
    }

    PFObject *object = [self.tasks objectAtIndex:indexPath.row];
    cell.taskLabel.text = object[@"description"];
    if ([object[@"status"] isEqual:@"complete"]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    PFFile *file = (PFFile *)object[@"resource"];
    [cell.taskImage sd_setImageWithURL:[NSURL URLWithString:file.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    if (section == 0) {
        title = @"Tasks";
    }
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *task = [self.tasks objectAtIndex:indexPath.row];
    if (task[@"status"] == nil || [task[@"status"] isEqual:@"incomplete"]) {
        task[@"status"] = @"complete";
    }else if([task[@"status"] isEqual:@"complete"]){
        task[@"status"] = @"incomplete";
    }
    [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
