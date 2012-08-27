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
@property (nonatomic, strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize tape = _tape;
@synthesize listOfVariables = _listOfVariables;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize decimalAlreadyPressed = _decimalAlreadyPressed;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;


- (CalculatorBrain *) brain{
    // Lazily instantiate the brain
    if (!_brain) {
        _brain = [[CalculatorBrain alloc]init];
    }
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else if (![@"0" isEqualToString:digit]) {
        // Prevent the user from entering leading zeros
        self.display.text = digit;
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
    [self updateDisplay];
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = [sender currentTitle];

//    // remove the equals sign from tape, if it exists.
//    if ([self.tape.text hasSuffix:@"="]) {
//        self.tape.text = [self.tape.text substringToIndex:self.tape.text.length -1];
//    }
//    
    // call enterPressed to push operand
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }    
    
    // if the operation is clear, then clear tape, otherwise append operation with equals sign.
    if ([operation isEqualToString:@"C"]) {
        self.tape.text = @"";
        self.display.text = @"0";
    }else {
        [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
        [self updateDisplay];
        self.tape.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    }
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.decimalAlreadyPressed = NO;
}

- (IBAction)backSpace {
    // if the user is in the middle of entering a number, remove the last digit, or decimal.
    if (self.userIsInTheMiddleOfEnteringANumber) {
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
    }else {
        [self.brain performOperation:@"changeSign"];
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *variable = [sender currentTitle];
    [self.brain pushVariable:variable];
    [self updateDisplay];
}

- (IBAction)runTest:(UIButton *)sender {
    NSLog(@"Test button pressed. title: %@", sender.currentTitle);
    
    if ([sender.currentTitle isEqualToString: @"Test 1"]) {
        NSLog(@"test1");
        self.testVariableValues = [[NSDictionary alloc]initWithObjectsAndKeys: @"5", @"a", @"4.8", @"b", @"0", @"x", nil ];
    }
    if ([sender.currentTitle isEqualToString: @"Test 2"]) {
        NSLog(@"test1");
        self.testVariableValues = [[NSDictionary alloc]initWithObjectsAndKeys:@"500.4", @"a", @"234.8", @"b", @"0.2", @"x" , nil ];
    }
    if ([sender.currentTitle isEqualToString: @"Test 3"]) {
        NSLog(@"test1");
        self.testVariableValues = [[NSDictionary alloc]initWithObjectsAndKeys: @"15", @"a", @".48", @"b", @"40", @"x", nil ];
    }
    NSLog(@"Here is the testVariableValues dictionary: %@", self.testVariableValues);
    [self populateListOfVariablesDisplay];
}

- (void)populateListOfVariablesDisplay{
    NSLog(@"populateListOfVariablesDisplay.");
    self.listOfVariables.text = @"";
    for (id key in [self.testVariableValues allKeys]) {
        NSLog(@"%@ = %@",key,[self.testVariableValues objectForKey:key]);
        self.listOfVariables.text = [self.listOfVariables.text stringByAppendingFormat:@"%@ = %@; ", key,[self.testVariableValues objectForKey:key]];
    }
}

- (void)updateDisplay{
    NSLog(@"Updating display.");
    self.display.text = [NSString stringWithFormat:@"%f", [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
}

- (void)viewDidUnload {
    [self setTape:nil];
    [self setDisplay:nil];
    [self setListOfVariables:nil];
    [super viewDidUnload];
}
@end
