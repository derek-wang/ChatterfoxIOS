//
//  ViewController.m
//  cloudmessaging
//
//  Created by Datton User on 2015-08-17.
//  Copyright (c) 2015 Datton User. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AudioToolbox/AudioToolbox.h"

NSString *userId = nil;
NSString *urlRoomId = nil;
NSTimer *timer;

static NSString *cfUrlString = @"http://cf.dev.datton.ca/mobile#/";
static NSString *cfUserProfileUrlString = @"http://cf.dev.datton.ca/api/user/profile";
static NSString *csrfUrlString = @"http://cf.dev.datton.ca/api";
static NSString *cfPostGCMTokenUrlString = @"http://cf.dev.datton.ca/api/gcmToken";
static NSString *cfRoomUrlString = @"http://cf.dev.datton.ca/mobile#/room/%@";

@implementation ViewController
@synthesize mainWebView;
@synthesize player;

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRegistrationStatus:)
                                                 name:appDelegate.registrationKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showReceivedMessage:)
                                                 name:appDelegate.messageKey
                                               object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgrounding) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foreground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [_activityIndicator startAnimating];
    
    mainWebView.delegate = self;
    // load cf starts
    NSURL *cfUrl = [NSURL URLWithString:cfUrlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL: cfUrl];
    
    [mainWebView loadRequest:request];
    
    NSLog(@"This is it");    
    // load cf ends
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"mp3"]];
    [self setPlayer:[[AVPlayer alloc] initWithPlayerItem:item]];
    
    [[self player] setActionAtItemEnd:AVPlayerActionAtItemEndNone];
  
}

- (void)backgrounding {
    if(player.rate == 0) {
        [[self player] play];
        NSLog(@"Play player and start 30 secs timer");
    
        timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(activing :) userInfo:nil repeats:NO];
    }
}

- (void)activing:(NSTimer *)timer {
    if(player.rate != 0 && !player.error) {
        [[self player] pause];
        NSLog(@"Pause player");
    }
}

- (void)foreground {
    if(player.rate != 0 && !player.error) {
        [[self player] pause];
        [timer invalidate];
        NSLog(@"Pause player and stop timer");
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *requestUrl = [[request URL] absoluteString];
    NSLog(@"url %@", requestUrl);

    int isLoginPage = [requestUrl rangeOfString:@"mobile#/login"].location;
    if(isLoginPage != NSNotFound) {
        NSString *saveUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        
        NSString *username = [NSString stringWithFormat:@"document.LoginForm.username.value = '%@'", saveUsername];
        NSString *password = [NSString stringWithFormat:@"document.LoginForm.password.value = '%@'", savedPassword];
        [self.mainWebView stringByEvaluatingJavaScriptFromString: username];
        [self.mainWebView stringByEvaluatingJavaScriptFromString: password];
        [self.mainWebView stringByEvaluatingJavaScriptFromString: @"$('#username').trigger('change')"];
        [self.mainWebView stringByEvaluatingJavaScriptFromString: @"$('#password').trigger('change')"];
    }
    
    if([requestUrl isEqualToString:cfUrlString]) {
        NSString *caughtUsername = [self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.LoginForm.username.value"];
        NSString *caughtPassword = [self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.LoginForm.password.value"];
        NSLog(@"Name %@", caughtUsername);
        NSLog(@"Password %@", caughtPassword);
        if(caughtUsername.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:caughtUsername forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:caughtPassword forKey:@"password"];
        }
    }
    
    // Save room id to avoid reload once notification comes in
    int indexOfRoom = [requestUrl rangeOfString:@"mobile#/room/"].location;
    if(indexOfRoom != NSNotFound) {
        NSLog(@"mobile room ##### %@", [NSString stringWithFormat:@"%i", indexOfRoom]);
        
        urlRoomId = [requestUrl substringWithRange:NSMakeRange(indexOfRoom + 13, [requestUrl length] - indexOfRoom - 13)];
        
        NSLog(@"Extract mobile room ID ##### %@", urlRoomId);
        //[[NSUserDefaults standardUserDefaults] setObject:urlRoomId forKey:@"RoomId"];
        
    }
    // Save room id to avoid reload once notification comes in
    
    if(userId == nil) {
        // user profile
        NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: cfUserProfileUrlString]];
        NSData *returnData = [NSURLConnection sendSynchronousRequest: request2 returningResponse: nil error: nil];
        NSString *responseBody = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSData *data = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *profileJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *userInfo = [profileJson objectForKey:@"result"];
        userId = [userInfo objectForKey:@"id"];
        NSLog(@"return USER ID %@", userId);
        // user profile
        
        // gcm token
        NSString *gcmToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"GCMToken"];
        NSLog(@"return GGCM KEY %@", gcmToken);
        // gcm token
        
        // get csrf token
        NSString *csrfToken;
        NSURL *csrfUrl = [NSURL URLWithString:csrfUrlString];
        NSURLRequest *request3 = [NSURLRequest requestWithURL: csrfUrl];
        NSHTTPURLResponse *response3;
        
        [NSURLConnection sendSynchronousRequest: request3 returningResponse: &response3 error: nil];
        if ([response3 respondsToSelector:@selector(allHeaderFields)]) {
            NSDictionary *dictionary = [response3 allHeaderFields];
            csrfToken = [dictionary objectForKey:@"X-CSRF-TOKEN"];
        }        
        // get csrf token
        
        // post gcm token to the server
        if(csrfToken != nil) {
            NSLog(@"CSRF-TOKEN ------ %@", csrfToken);
            NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
            NSString *post = [NSString stringWithFormat: @"{\"id\":\"%@\",\"phoneOs\":\"iOS\",\"deviceId\":\"%@\",\"token\":\"%@\"}", userId, deviceId, gcmToken];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            
            NSURLRequest *request4 = [NSURLRequest requestWithURL: [NSURL URLWithString:cfPostGCMTokenUrlString]];
            NSMutableURLRequest *mutableRequest4 = [request4 mutableCopy];
            
            [mutableRequest4 setHTTPMethod:@"POST"];
            [mutableRequest4 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [mutableRequest4 setValue:@"X-CSRF-HEADER" forHTTPHeaderField:@"X-CSRF-TOKEN"];
            [mutableRequest4 setValue:csrfToken forHTTPHeaderField: @"X-CSRF-TOKEN"];
            [mutableRequest4 setHTTPBody:postData];
            
            request4 = [mutableRequest4 copy];
            
            NSHTTPURLResponse *response = nil;
            NSData *returnData4 = [NSURLConnection sendSynchronousRequest: request4 returningResponse: &response error: nil];
            NSString *responseBody4 = [[NSString alloc] initWithData:returnData4 encoding:NSUTF8StringEncoding];
            
            if([response statusCode] == 200) {
                NSLog(@"Post GCM token to the server SUCCESSFULLY ------ %@", responseBody4);
            } else {
                NSLog(@"Post GCM token to the server FAILED -------------");
            }
        }
        // post gcm token to the server
    }
    return YES;
}

- (void) updateRegistrationStatus:(NSNotification *) notification {
//    [_activityIndicator stopAnimating];
//    if ([notification.userInfo objectForKey:@"error"]) {
//        _registeringLabel.text = @"Error registering!";
//        [self showAlert:@"Error registering with GCM" withMessage:notification.userInfo[@"error"]];
//    } else {
//        _registeringLabel.text = @"Registered!";
//        NSString *message = @"Check the xcode debug console for the registration token that you can"
//        " use with the demo server to send notifications to your device";
//        [self showAlert:@"Registration Successful" withMessage:message];
//    };
}

- (void) showReceivedMessage:(NSNotification *) notification {
    //NSString *message = notification.userInfo[@"aps"][@"alert"];
    
    if(userId != nil) {
        // check if the app is in foreground
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if(state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
            //        [self setupLocalNotifications];
            //        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            //        localNotification.userInfo = notification.userInfo;
            //        localNotification.alertBody = message;
            //        localNotification.fireDate = [NSDate date];
            //        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
            
            // load cf message room starts
            NSString *roomId = notification.userInfo[@"roomId"];
            //NSString *savedRoomId = [[NSUserDefaults standardUserDefaults] objectForKey:@"RoomId"];
            
            if(![roomId isEqualToString:urlRoomId]) {
                //self.activityIndicator.hidden = NO;
                //[self.activityIndicator startAnimating];
                NSString *roomUrlString = [NSString stringWithFormat: cfRoomUrlString, roomId];
                NSURL *roomUrl = [NSURL URLWithString:roomUrlString];
                
                NSURLRequest *request = [NSURLRequest requestWithURL: roomUrl];
                
                [mainWebView loadRequest:request];
                    
                //NSURLConnection *connectToRoom = [NSURLConnection connectionWithRequest:request delegate:self];
                //[[NSUserDefaults standardUserDefaults] setObject:roomId forKey:@"RoomId"];
            }
            // load cf message room ends
        } else {
            AudioServicesPlaySystemSound(1003);       
        }
    }
    
    //[self showAlert:@"Message received" withMessage:message];
}

//- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
//    NSLog(@"Finished loading");
//    self.activityIndicator.hidden = YES;
//    [self.activityIndicator stopAnimating];
//}

- (void)showAlert:(NSString *)title withMessage:(NSString *) message{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
    } else {
        //iOS 8 or later
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:nil];
        
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
