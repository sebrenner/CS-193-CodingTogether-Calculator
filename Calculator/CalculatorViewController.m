//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Scott Brenner on 7/3/12.
//  Copyright (c) 2012 Scott Brenner. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL decimalAlreadyPressed;
@property (nonatomic, strong) CalculatorBrain *brain;

@end

@implementation CalculatorViewController

@synthesize display;
@synthesize tape;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize decimalAlreadyPressed = _decimalAlreadyPressed;

@synthesize brain = _brain;

- (CalculatorBrain *) brain{
    // Lazily instantiate the brain
    if (!_brain) {
        _brain = [[CalculatorBrain alloc]init];
    }
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
        self.tape.text = [self.tape.text stringByAppendingFormat:digit];
    } else {
        // Prevent the user from entering leading zeros
        if (![@"0" isEqualToString:digit]) {
            self.display.text = digit;
            self.tape.text = [self.tape.text stringByAppendingFormat:@" %@", digit];
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
    }
}

- (IBAction)decimalPressed:(UIButton *)sender {
    // prevent the user from entering more than one decimal
    if (!self.decimalAlreadyPressed) {
        [self digitPressed:sender];
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if(userIsInTheMiddleOfEnteringANumber){
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.tape.text = [self.tape.text stringByAppendingFormat:@" %@", operation];
    self.display.text = [NSString stringWithFormat:@"%g",result];
}

- (IBAction)clearOperation {
    [self.brain clearStack];
    self.display.text = [NSString stringWithFormat:@"0"];
    self.tape.text = [NSString stringWithFormat:@""];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.decimalAlreadyPressed = NO;
}

- (void)viewDidUnload {
    [self setTape:nil];
    [self setDisplay:nil];
    [super viewDidUnload];
}
@end
