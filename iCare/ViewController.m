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

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate,PFLogInViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (strong, nonatomic) NSArray *tasks;
@property (strong, nonatomic) NSMutableArray *incompleteTasks;
@property (strong, nonatomic) NSString *status;
@property(nonatomic, strong) PFLogInViewController *logInController;
@end

@implementation ViewController

- (void)viewDidLoad {
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *code = [SSKeychain passwordForService:appName account:@"icare"];
    NSLog(@"code %@",code);

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
//    [self.taskTableView registerClass:[TaskWithImageTableViewCell class] forCellReuseIdentifier:@"taskImageCellIdentifier"];
}

- (NSMutableString *) randomStringWithLength:(int) len {
    
    NSString *letters  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString  = [[NSMutableString alloc]initWithCapacity:len];
    
    for (int i=0; i < len; i++){
        NSUInteger rand = arc4random_uniform(letters.length);
        randomString = [randomString stringByAppendingFormat:@"%C", [letters characterAtIndex:rand]];
    }
    return randomString;
}


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    NSLog(@"didLogInUser %@",user);

//    NSString *random = [self randomStringWithLength:5];
//    NSLog(@"random string %@",random);
//    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
//    [SSKeychain setPassword:random forService:appName account:@"icare"];
//
//    NSString *codeString = [NSString stringWithFormat:@"%@:%@",@"Share this code with your loved one whom you care for",random];
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Code" message:codeString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    
    [self.logInController dismissViewControllerAnimated:NO completion:nil];
    self.taskTableView.dataSource = self;
    self.taskTableView.delegate = self;
    
    [self fetchIncompleteTasks];

}

- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(PFUI_NULLABLE NSError *)error{
    NSLog(@"didFailToLogInWithError %@",error);
}

- (void)fetchIncompleteTasks{
    self.tasks = nil;
    self.tasks = [[NSArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"task"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        self.incompleteTasks = [[NSMutableArray alloc]init];
        
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PFObject *task = (PFObject *)objects[idx];
            if ([task[@"status"] isEqual:@"incomplete"]) {
                [self.incompleteTasks addObject:task];
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
//    if ([object[@"status"] isEqual:@"complete"]) {
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//    }else{
//        [cell setAccessoryType:UITableViewCellAccessoryNone];
//    }
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
    PFObject *task = [self.incompleteTasks objectAtIndex:indexPath.row];
    if (task[@"status"] == nil || [task[@"status"] isEqual:@"incomplete"]) {
        task[@"status"] = @"complete";
    }

    
//    else if([task[@"status"] isEqual:@"complete"]){
//        task[@"status"] = @"incomplete";
//    }
//    [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//        if (succeeded) {
//            [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
//        }
//    }];

    [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [self fetchIncompleteTasks];
//            [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
