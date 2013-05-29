//
//  GOTWebViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 5/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTWebViewController.h"

#import "GOTConstants.h"

@implementation GOTWebViewController

@synthesize request;

- (id)initWithURLRequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        request = req;
    }
    return self;
}

- (void)viewDidLoad
{
    if (request) {
        [webView loadRequest:[self request]];
    }
}

- (UIWebView *)webView
{
    return webView;
}


- (IBAction)refresh:(id)sender {
    [webView reload];
}

- (IBAction)action:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSURL *url = [request URL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
