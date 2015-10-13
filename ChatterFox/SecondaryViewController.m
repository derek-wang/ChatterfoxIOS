//
//  SecondaryViewController.m
//  ChatterFox
//
//  Created by Datton User on 2015-09-25.
//  Copyright © 2015 Datton User. All rights reserved.
//

#import "SecondaryViewController.h"
#import "RemoteImageView.h"


@implementation SecondaryViewController

@synthesize link;
@synthesize documentWebView;

RemoteImageView *imageView;
NSURLRequest *documentRequest;
NSURLConnection *conn;
UIScrollView *scrollView;

- (void)viewDidLoad {
    [_documentLoadIndicator startAnimating];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    imageView = [[RemoteImageView alloc] initWithFrame: self.view.frame];
    imageView.showActivityIndicator = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Pass main view controller link %@", link);
    NSURL *documentUrl = [NSURL URLWithString: link];
    
    documentRequest = [NSURLRequest requestWithURL: documentUrl];    
    conn = [NSURLConnection connectionWithRequest:documentRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSString *mime = [response MIMEType];
    NSLog(@"MIME Type is %@", mime);
    if([mime rangeOfString:@"image/"].location != NSNotFound) {
        imageView.imageURL = [NSURL URLWithString: link];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        scrollView.contentInset = UIEdgeInsetsMake(-38, 0, 0, 0);
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        float rw = self.view.bounds.size.width / self.view.bounds.size.width;
        scrollView.minimumZoomScale = rw;
        scrollView.maximumZoomScale = rw + 1;
        scrollView.zoomScale = rw;
        
        scrollView.delegate = self;
        [scrollView addSubview:imageView];
        [self.view addSubview:scrollView];
        
        imageView.completeBlock = ^(UIImage *image) {
            NSLog(@"image finished loading");
            [_documentLoadIndicator stopAnimating];
        };
    } else {
        documentWebView.delegate = self;
        [documentWebView loadRequest:documentRequest];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    [_documentLoadIndicator stopAnimating];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // navigation button was pressed then stop all requests in there
        NSLog(@"Back button pressed");
        [documentWebView loadHTMLString:nil baseURL:nil];
        [RemoteImageView cancelAll];
        //[RemoteImageView clearCache];
    }
    [super viewWillDisappear:animated];
}

@end
