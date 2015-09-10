//
//  ViewController.h
//  cloudmessaging
//
//  Created by Datton User on 2015-08-17.
//  Copyright (c) 2015 Datton User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"

@interface ViewController : UIViewController<UIWebViewDelegate, NSURLConnectionDelegate>

@property(nonatomic, weak) IBOutlet UILabel *registeringLabel;
@property (strong, nonatomic) IBOutlet UIWebView *mainWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
extern NSString *userId;
@property (nonatomic, strong) AVPlayer *player;

@end

