//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Scott Brenner on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *display;
@property (strong, nonatomic) IBOutlet UILabel *tape;
@property (strong, nonatomic) IBOutlet UILabel *listOfVariables;

@end
