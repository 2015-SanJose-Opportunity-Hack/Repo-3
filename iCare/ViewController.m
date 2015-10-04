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
#import <ParseUI/ParseUI.h>
#import "SSKeychain.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate,PFLogInViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (strong, nonatomic) NSArray *tasks;
@property (strong, nonatomic) NSMutableArray *incompleteTasks;
@property (strong, nonatomic) NSString *status;
@property(nonatomic, strong) PFLogInViewController *logInController;
@end

@implementation ViewController
- (IBAction)call911:(id)sender {
    NSString *phNo = @"911";
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *phNo;
    switch (buttonIndex) {
        case 0:
            phNo = @"911";
            break;
        case 1:
            phNo = @"211";
            break;
        case 2:
            phNo = @"6693009396";
            break;
        case 3:
            break;
        default:
            break;
    }
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }

}

- (IBAction)callActionSheet:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]init];
    [sheet addButtonWithTitle:@"911"];
    [sheet addButtonWithTitle:@"211"];
    [sheet addButtonWithTitle:@"Jason"];
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    sheet.delegate = self;
    [sheet showInView:self.view];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    if ([PFUser currentUser] == nil) {
        self.logInController = [[PFLogInViewController alloc] init];
        self.logInController.delegate = self;
        self.logInController.fields = (PFLogInFieldsUsernameAndPassword
                                       | PFLogInFieldsLogInButton
                                       | PFLogInFieldsSignUpButton
                                       | PFLogInFieldsPasswordForgotten
                                       | PFLogInFieldsDismissButton);
        [self presentViewController:self.logInController animated:NO completion:nil];
    }else{
        self.taskTableView.dataSource = self;
        self.taskTableView.delegate = self;
        
        [self fetchIncompleteTasks];
    }
}

- (NSMutableString *) randomStringWithLength:(int) len {
    
    NSString *letters  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *onlyLetters  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *randomString  = [[NSMutableString alloc]initWithCapacity:len];
    
    for (int i=0; i < len; i++){
        NSUInteger rand;
        if (i == 0) {
            rand = arc4random_uniform(onlyLetters.length);
        }else{
            rand = arc4random_uniform(letters.length);
        }
        randomString = [randomString stringByAppendingFormat:@"%C", [letters characterAtIndex:rand]];
    }
    return randomString;
}


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    NSLog(@"didLogInUser %@",user);

    [self.logInController dismissViewControllerAnimated:NO completion:nil];
    
    NSString *random = [self randomStringWithLength:5];
    NSLog(@"random string %@",random);
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    [SSKeychain setPassword:random forService:appName account:@"icare"];
    
    NSString *codeString = [NSString stringWithFormat:@"%@:%@",@"Share this code with your family:",random];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Code" message:codeString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(PFUI_NULLABLE NSError *)error{
    NSLog(@"didFailToLogInWithError %@",error);
}

- (void)fetchIncompleteTasks{
    self.tasks = nil;
    self.tasks = [[NSArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"task"];

    //cancel all local notifications before scheduling new ones
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    [query whereKey:@"uniqueCode" equalTo:[SSKeychain passwordForService:appName account:@"icare"]];
    [query orderByAscending:@"t_date"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        self.incompleteTasks = [[NSMutableArray alloc]init];
        
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PFObject *task = (PFObject *)objects[idx];
            if ([task[@"status"] isEqual:@"incomplete"]) {
                [self.incompleteTasks addObject:task];
                [self scheduleLocalNotification:task[@"t_date"] andBody:task[@"description"]];
            }
        }];
        PFObject *obj = (PFObject *)objects[0];
        PFFile *file = (PFFile *)obj[@"resource"];
        NSLog(@"objects %@",file.url);
        self.tasks = objects;
        [self.taskTableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.incompleteTasks.count;
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

    PFObject *object = [self.incompleteTasks objectAtIndex:indexPath.row];
    cell.taskLabel.text = object[@"description"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *formattedDate = [formatter stringFromDate:object[@"t_date"]];
    cell.timeLabel.text = formattedDate;
    PFFile *file = (PFFile *)object[@"resource"];
    
    [cell.taskImage sd_setImageWithURL:[NSURL URLWithString:file.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    if (cell.taskImage.image == nil) {
        cell.taskImage.image = [UIImage imageNamed:@"medicine"];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    if (section == 0) {
        title = @"Tasks";
    }
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *task = [self.incompleteTasks objectAtIndex:indexPath.row];
    if (task[@"status"] == nil || [task[@"status"] isEqual:@"incomplete"]) {
        task[@"status"] = @"complete";
    }

    [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [self fetchIncompleteTasks];
        }
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scheduleLocalNotification:(NSDate *)date andBody:(NSString *)body{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setFireDate:date];
    [notification setAlertBody:body];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
