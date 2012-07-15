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

@synthesize display = _display;
@synthesize tape = _tape;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
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
    // remove the equals sign from tape, if it exists.
    if ([self.tape.text hasSuffix:@"="]) {
        self.tape.text = [self.tape.text substringToIndex:self.tape.text.length -1];
    }

    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
        self.tape.text = [self.tape.text stringByAppendingFormat:digit];
    } else if (![@"0" isEqualToString:digit]) {
        // Prevent the user from entering leading zeros
        self.display.text = digit;
        self.tape.text = [self.tape.text stringByAppendingFormat:@" %@", digit];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)decimalPressed:(UIButton *)sender {
    // prevent the user from entering more than one decimal
    if (!self.decimalAlreadyPressed) {
        [self digitPressed:sender];
        self.decimalAlreadyPressed = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = [sender currentTitle];

    // remove the equals sign from tape, if it exists.
    if ([self.tape.text hasSuffix:@"="]) {
        self.tape.text = [self.tape.text substringToIndex:self.tape.text.length -1];
    }
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g",result];
    self.tape.text = [self.tape.text stringByAppendingFormat:@" %@ =", operation];    
}

- (IBAction)clearOperation {
    [self.brain clearStack];
    self.display.text = [NSString stringWithFormat:@"0"];
    self.tape.text = [NSString stringWithFormat:@""];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.decimalAlreadyPressed = NO;
}
- (IBAction)backSpace {
    // if the user is in the middle of entering a number, remove the last digit, or decimal.
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.tape.text = [self.tape.text substringToIndex:self.tape.text.length - 1];
        self.display.text = [self.display.text substringToIndex:self.display.text.length -1];
        if (self.display.text.length < 1) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }else {
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
    }else {
        NSLog(@"user pressed backspace, but they weren't in the middle of editing.");
    }
}

- (void)viewDidUnload {
    [self setTape:nil];
    [self setDisplay:nil];
    [super viewDidUnload];
}
@end
