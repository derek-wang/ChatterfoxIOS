//
//  SettingController.m
//  ChatterFox
//
//  Created by Datton User on 2015-09-23.
//  Copyright © 2015 Datton User. All rights reserved.
//

#import "SettingController.h"

@implementation SettingController

@synthesize settingTableView;

- (void)viewDidLoad {
    settingTableView.delegate = self; 
    settingTableView.allowsSelection = NO;
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    if ([[standardDefaults stringForKey:@"enableNotification"] isEqualToString:@"OFF"]) {
        self.enableNotification.on = NO;
    } else {
        self.enableNotification.on = YES;
    }
}

- (IBAction)enableNotificationDidChangeValue:(id)sender {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    if(self.enableNotification.on) {
        if(![self isHaveRegistrationForNotification]) {
            NSLog(@"Enabled Notification-------------------------");
            [standardDefaults setObject:@"ON" forKey:@"enableNotification"];
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
                // iOS 8 Notifications
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
            else {
                // iOS < 8 Notifications
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                 (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
            }
        }
    } else {
        NSLog(@"Disabled Notification-------------------------");
        [standardDefaults setObject:@"OFF" forKey:@"enableNotification"];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (IBAction)helpClicked:(id)sender {
    NSString* launchUrl = @"https://www.chatterfox.ca/mobile-help-automotive/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

- (BOOL)isHaveRegistrationForNotification {
    //For ios >= 8.0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    } else {
        //For ios < 8
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        BOOL deviceEnabled = !(types == UIRemoteNotificationTypeNone);
        return deviceEnabled;
    }
}

@end
