//
//  SecondaryViewController.h
//  ChatterFox
//
//  Created by Datton User on 2015-09-25.
//  Copyright © 2015 Datton User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondaryViewController : UIViewController<UIWebViewDelegate>

@property(nonatomic) NSString *link;
@property (strong, nonatomic) IBOutlet UIWebView *documentWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *documentLoadIndicator;

@end
