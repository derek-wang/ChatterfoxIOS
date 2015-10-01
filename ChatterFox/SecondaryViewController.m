//
//  SecondaryViewController.m
//  ChatterFox
//
//  Created by Datton User on 2015-09-25.
//  Copyright © 2015 Datton User. All rights reserved.
//

#import "SecondaryViewController.h"



@implementation SecondaryViewController

@synthesize link;
@synthesize documentWebView;

- (void)viewDidLoad {
    documentWebView.delegate = self;
    [_documentLoadIndicator startAnimating];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Pass main view controller link %@", link);
    NSURL *documentUrl = [NSURL URLWithString: link];
    
    NSURLRequest *documentRequest = [NSURLRequest requestWithURL: documentUrl];
    
    [documentWebView loadRequest:documentRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    [_documentLoadIndicator stopAnimating];
    CGSize contentSize = theWebView.scrollView.contentSize;
    CGSize viewSize = theWebView.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    theWebView.scrollView.minimumZoomScale = rw;
    theWebView.scrollView.maximumZoomScale = rw + 1;
    theWebView.scrollView.zoomScale = rw;
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // navigation button was pressed then stop all requests in there
        NSLog(@"Back button pressed");
        [documentWebView loadHTMLString:nil baseURL:nil];
    }
    [super viewWillDisappear:animated];
}

@end
