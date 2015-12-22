//
//  LoginViewController.m
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatViewController.h"
#import <MBProgressHUD.h>

#import <Quickblox/Quickblox.h>

NSString* const defaultPassword = @"defaultPassword";

@interface LoginViewController ()

@property (weak, nonatomic) UITableView* tableView;

@property (strong, nonatomic) NSArray* dataSource;

@end

@implementation LoginViewController

#pragma mark - Load data

- (void) loadUsers {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.labelText = @"Loading users";
    [QBRequest usersWithSuccessBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users) {
        [hud hide: YES];
        self.dataSource = users;
        [self.tableView reloadData];
    } errorBlock:^(QBResponse * _Nonnull response) {
        [hud hide: YES];
        NSLog(@"Error fetching users. Response: %@", response);
    }];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame: self.view.bounds style: UITableViewStylePlain];
    [self.view addSubview: tableView];
    tableView.tableFooterView = [UIView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.tableView = tableView;
    [self loadUsers];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect titleFrame = CGRectMake(0, 0, 200.0, 35.0);
    UIImageView* titleImageView = [[UIImageView alloc] initWithFrame: titleFrame];
    titleImageView.image = [UIImage imageNamed:@"LOGO_sequenia"];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleImageView;
    
}

#pragma mark - Requests

- (void) signUpWithUser: (QBUUser*) user {
    [QBRequest signUp:user successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        NSLog(@"Sign Up Successful. Response: %@", response);
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Sign Up Error. Response: %@", response);
    }];
}

- (void) loginWithUser: (QBUUser*) user {

    user.password = defaultPassword;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.labelText = @"Login";
    [QBRequest logInWithUserLogin: user.login password: user.password successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable _user) {
        NSLog(@"Login Successful. Response: %@", response);
        
        // Connect
        hud.labelText = @"Connecting";
        if ([[QBChat instance] isConnected]) {
            [hud hide:YES];
            [self gotoChatViewcontrollerWithUser: user];
            return;
        }
        
        [[QBChat instance] connectWithUser: user completion:^(NSError * _Nullable error) {
            [hud hide: YES];
            if (error){
                NSLog(@"Error chat connecting : %@", error.localizedDescription);
            } else {
                [self gotoChatViewcontrollerWithUser: user];
            }
        }];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        [hud hide: YES];
        NSLog(@"Login Error. Response: %@", response);
    }];
}

#pragma mark - Helpers

- (void) createUsers {
    self.dataSource = @[[self userWithLogin: @"FirstUser"],
                        [self userWithLogin: @"SecondUser"]];
}

- (QBUUser*) userWithLogin: (NSString*) login {
    QBUUser* user = [QBUUser user];
    user.login = login;
    user.password = defaultPassword;
    user.fullName = login;
    return user;
}

- (void) gotoChatViewcontrollerWithUser: (QBUUser*) user {
    ChatViewController* chatVC = [[ChatViewController alloc] initWithUser: user];
    UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController: chatVC];
    chatVC.navigationItem.titleView = self.navigationItem.titleView;
    [self presentViewController: navigationVC animated: YES completion: nil];
}

@end

#pragma mark - UITableViewDataSource

@implementation LoginViewController (UITableViewDataSource)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    QBUUser* user = self.dataSource[indexPath.row];
    cell.textLabel.text = user.fullName;
    return cell;
}

@end

#pragma mark - UITableViewDelegate

@implementation LoginViewController (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    QBUUser* user = self.dataSource[indexPath.row];
    [self loginWithUser: user];
}



@end
