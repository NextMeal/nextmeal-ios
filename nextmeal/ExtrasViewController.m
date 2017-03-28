//
//  ExtrasViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/27/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "ExtrasViewController.h"

@interface ExtrasViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;

@property (weak, nonatomic) IBOutlet UIButton *uberButton;
@property (weak, nonatomic) IBOutlet UIButton *lyftButton;
@property (weak, nonatomic) IBOutlet UIButton *shipmateButton;
@property (weak, nonatomic) IBOutlet UITextView *taxiTextView;

@end

@implementation ExtrasViewController

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
    //[self viewWillAppear:animated];
    [_aboutTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    [_taxiTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = YES;
    
    _versionLabel.text = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSError *error;
    NSString *aboutText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    _aboutTextView.text = error ? error.localizedDescription : aboutText;
    
    error = nil;
    NSString *taxiText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"taxi" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    _taxiTextView.text = error ? error.localizedDescription : taxiText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
