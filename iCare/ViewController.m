//
//  ViewController.m
//  iCare
//
//  Created by Akshay on 10/3/15.
//  Copyright (c) 2015 akshay. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

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
    
    self.tasks = [[NSArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"task"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        self.status = [objects valueForKey:@"status"];
        if (!error && ([self.status isEqual:(@"completed")])) {
            self.tasks = objects;
            [self.taskTableView reloadData];
        }
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tasks.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"taskIdentifier"];
    PFObject *object = [self.tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = object[@"description"];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
