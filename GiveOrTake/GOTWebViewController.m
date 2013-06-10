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
    activityIndicator.color = [UIColor darkGrayColor];
    [webView setDelegate:self];
    if (request) {
        [webView loadRequest:[self request]];
    }
}

- (UIWebView *)webView
{
    return webView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
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

- (void)dealloc
{
    [webView setDelegate:nil];
}

@end
