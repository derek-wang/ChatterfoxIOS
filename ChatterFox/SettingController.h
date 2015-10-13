//
//  SettingController.h
//  ChatterFox
//
//  Created by Datton User on 2015-09-23.
//  Copyright © 2015 Datton User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *helpBtn;
@property (weak, nonatomic) IBOutlet UISwitch *enableNotification;
@property (strong, nonatomic) IBOutlet UITableView *settingTableView;
@property (weak, nonatomic) IBOutlet UIButton *clearImageCacheBtn;

- (IBAction)enableNotificationDidChangeValue:(id)sender;
- (IBAction)helpClicked:(id)sender;
- (IBAction)clearImageCacheClicked:(id)sender;


@end
