//
//  LoginViewController.h
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@end

@interface LoginViewController (UITableViewDataSource) <UITableViewDataSource>

@end

@interface LoginViewController (UITableViewDelegate) <UITableViewDelegate>

@end