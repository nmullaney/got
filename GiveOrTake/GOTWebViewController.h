//
//  GOTWebViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 5/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOTWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
    IBOutlet UIView *view;
    
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    
    __weak IBOutlet UIWebView *webView;
}

@property (nonatomic, copy) NSURLRequest *request;

- (id)initWithURLRequest:(NSURLRequest *)request;

- (IBAction)refresh:(id)sender;
- (IBAction)action:(id)sender;

@end
