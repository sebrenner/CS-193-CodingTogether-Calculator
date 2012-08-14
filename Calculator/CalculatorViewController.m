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
        self.tape.text = [self.tape.text stringByAppendingString:digit];
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
    
    // press enter to push operand
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }    
    
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g",result];

    // if the operation is clear, then clear tape, otherwise append operation with equals sign.
    if ([operation isEqualToString:@"C"]) {
        self.tape.text = @"";
    }else {
        self.tape.text = [self.tape.text stringByAppendingFormat:@" %@ =", operation];
    }
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
    }
}
- (IBAction)changeSign {
    // if user is in middle of enter number, change sign of number, else change sign of number on brain stack.
    if (self.userIsInTheMiddleOfEnteringANumber) {
        double tempValue = [self.display.text doubleValue];
        tempValue = -1 * tempValue;
        self.display.text = [NSString stringWithFormat:@"%g", tempValue];
    }else {
        double result = [self.brain performOperation:@"changeSign"];
        self.display.text = [NSString stringWithFormat:@"%g",result];
    }
}


- (void)viewDidUnload {
    [self setTape:nil];
    [self setDisplay:nil];
    [super viewDidUnload];
}
@end
