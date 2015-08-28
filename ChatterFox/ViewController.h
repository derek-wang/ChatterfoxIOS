//
//  ViewController.h
//  cloudmessaging
//
//  Created by Datton User on 2015-08-17.
//  Copyright (c) 2015 Datton User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIWebViewDelegate, NSURLConnectionDelegate>

@property(nonatomic, weak) IBOutlet UILabel *registeringLabel;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *registrationProgressing;
@property (strong, nonatomic) IBOutlet UIWebView *mainWebView;
@property(strong, nonatomic) UIActivityIndicatorView *activityIndicator;
extern NSString *userId;
@end

