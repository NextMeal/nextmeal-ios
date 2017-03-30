//
//  ExtrasViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/27/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "ExtrasViewController.h"

#import "Constants.h"

#import "FeedbackTextFieldDelegate.h"

@import MapKit;

@interface ExtrasViewController ()

@property FeedbackTextFieldDelegate *feedbackTextFieldDelegate;
@property UIAlertController *sendingAlertController;

@property (weak, nonatomic) IBOutlet MKMapView *backgroundMapView;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;

@property (weak, nonatomic) IBOutlet UIButton *uberButton;
@property (weak, nonatomic) IBOutlet UIButton *lyftButton;
@property (weak, nonatomic) IBOutlet UIButton *shipmateButton;
@property (weak, nonatomic) IBOutlet UITextView *taxiTextView;

@end

@implementation ExtrasViewController

- (void)sendFeedbackAction:(NSString *)feedback {
    //NSURLSession version of
    //http://stackoverflow.com/questions/12358002/submit-data-to-google-spreadsheet-form-from-objective-c
    
    //initialize url that is going to be fetched.
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/forms/d/e/1FAIpQLSfq9oiddVHHDfPikoD3IGnoljuBcY7mRh8PFkr9aCVWFkiNGw/formResponse"];
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    
    //set http method
    [request setHTTPMethod:@"POST"];
    //initialize a post data
    NSString *postData = [NSString stringWithFormat:@"entry.822294369=%@", feedback];
    //set request content type we MUST set this value.
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initialize a connection from request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    _sendingAlertController = [UIAlertController
                               alertControllerWithTitle:@"Sending"
                               message:nil
                               preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_sendingAlertController animated:YES completion:nil];
    
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [_sendingAlertController dismissViewControllerAnimated:YES completion:^() {
            UIAlertController *sentAlert = [UIAlertController
                                            alertControllerWithTitle:error ? @"Unable to send. Please try later." : @"Sent successfully!"
                                            message:error ? error.localizedDescription : nil
                                            preferredStyle:UIAlertControllerStyleAlert];
            [sentAlert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:sentAlert animated:YES completion:nil];
        }];
    }];
    
    [uploadTask resume];
}


- (IBAction)feedbackButtonClicked:(id)sender {
    UIAlertController *feedbackAlert = [UIAlertController
                                        alertControllerWithTitle:@"Ideas and Suggestion Box"
                                        message:nil
                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sendAction = [UIAlertAction
                                 actionWithTitle:@"Send"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self sendFeedbackAction:feedbackAlert.textFields.firstObject.text];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       [feedbackAlert dismissViewControllerAnimated:YES completion:nil];
                                   }];
    
    [feedbackAlert addTextFieldWithConfigurationHandler:^(UITextField *textfield) {
        _feedbackTextFieldDelegate = [[FeedbackTextFieldDelegate alloc] init];
        _feedbackTextFieldDelegate.createAction = sendAction;
        textfield.delegate = _feedbackTextFieldDelegate;
        textfield.placeholder = @"Your suggestion here.";
        textfield.autocorrectionType = UITextAutocorrectionTypeDefault;
        textfield.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textfield.keyboardAppearance = UIKeyboardAppearanceAlert;
        sendAction.enabled = NO;
    }];
    
    [feedbackAlert addAction:sendAction];
    [feedbackAlert addAction:cancelAction];
    
    [self presentViewController:feedbackAlert animated:YES completion:nil];
}

- (IBAction)taxiButtonClicked:(id)sender {
    NSString *testURL;
    NSString *targetURL;
    NSString *fallbackURL;
    
    if (sender == _uberButton) {
        testURL = @"uber://";
        targetURL = @"uber://?client_id=lFeNItEcE-FLjTklDS1rqCzpzSuhUUQY";
        fallbackURL = @"https://m.uber.com/ul/?client_id=lFeNItEcE-FLjTklDS1rqCzpzSuhUUQY";
    } else if (sender == _lyftButton) {
        testURL = @"lyft://";
        targetURL = @"lyft://partner=Saq2gjazKNFw&credits=nextmeal";
        fallbackURL = @"https://www.lyft.com/signup/SDKSIGNUP?clientId=Saq2gjazKNFw&sdkName=iOS_direct&credits=nextmeal";
    } else if (sender == _shipmateButton) {
        testURL = @"shipmate://";
        targetURL = @"shipmate://?origin=nextmeal";
        fallbackURL = @"tel:4103205961";
    } else {
        NSLog(@"Unknown sender %@.", sender);
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:testURL]]) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:targetURL] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:targetURL]];
        }
    } else {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fallbackURL] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fallbackURL]];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSError *error;
    NSString *aboutText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    
    NSInteger seedCount = [[NSUserDefaults standardUserDefaults] integerForKey:kP2PSeedTotal];
    NSInteger leachCount = [[NSUserDefaults standardUserDefaults] integerForKey:kP2PLeechTotal];
    double ratio = (double)seedCount / leachCount;
    NSString *statisticsText = [NSString stringWithFormat:@"Your P2P Menu Statistics (Experimental):\nSeeds: %ld\nLeechs: %ld\nS/L Ratio: %f%@", (long)seedCount, (long)leachCount, ratio, isnan(ratio) ? @"...to be seen!" : @""];
    
    NSString *aboutAndStatsText = [NSString stringWithFormat:@"%@\n\n%@", error ? error.localizedDescription : aboutText, statisticsText];
    
    _aboutTextView.text = aboutAndStatsText;
    
    [_aboutTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    [_taxiTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Hide nav bar
    self.navigationController.navigationBar.hidden = YES;
    
    //Set background map view to academy region
    [_backgroundMapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(38.98096, -76.48373), MKCoordinateSpanMake(0.05, 0.05)) animated:YES];
    
    _versionLabel.text = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSError *error;
    NSString *taxiText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"taxi" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    _taxiTextView.text = error ? error.localizedDescription : taxiText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
