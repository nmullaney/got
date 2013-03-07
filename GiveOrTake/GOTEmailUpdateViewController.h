//
//  GOTEmailUpdateViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOTEmailUpdateViewController : UIViewController
{
    
    __weak IBOutlet UITextField *emailField;
}

- (IBAction)updateEmail:(id)sender;

@end
