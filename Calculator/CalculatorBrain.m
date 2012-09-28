//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Scott Brenner on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

-(NSMutableArray *)programStack{
    // Lazilly instatiate the operandStack
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc]init];
    }
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in Homework #2";
}

-(void) pushOperand:(double)operand{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
//    NSLog(@"pushed operand %@", operandObject);
//    NSLog(@"The stack= %@", self.operandStack);
}

-(double) popOperand{
    // Get the last operand and remove it from the stack
    NSNumber *operandObject = [self.programStack lastObject];
    if (operandObject) {
        [self.programStack removeLastObject];
    }
    NSLog(@"The stack= %@", self.programStack);
    return [operandObject doubleValue];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] +
            [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] *
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) {
                result = [self popOperandOffProgramStack:stack] / divisor;
            }else{
                //  Cause a diagog box to pop up
                UIAlertView *alertDialog;
                alertDialog = [[UIAlertView alloc]
                               initWithTitle: @"Error: Divide by Zero"
                               message:@"You cannot divide by zero."
                               delegate: self
                               cancelButtonTitle: @"Ok"
                               otherButtonTitles: nil];
                alertDialog.alertViewStyle=UIAlertViewStyleDefault;
                [alertDialog show];
            }
        } else if ([@"C" isEqualToString:operation]) {
            //                [self.programStack removeAllObjects];
            result = 0;
        } else if ([@"π" isEqualToString:operation] ) {
            result=M_PI;
        } else if ([@"Sin" isEqualToString:operation] ) {
            result = sin([self popOperandOffProgramStack:stack]);
            [self popOperandOffProgramStack:stack];
        }
        
        if ([@"Cos" isEqualToString:operation] ) {
            result = cos([self popOperandOffProgramStack:stack]);
            [self popOperandOffProgramStack:stack];
        }
        
        if ([@"Sqrt" isEqualToString:operation] ) {
            result = sqrt([self popOperandOffProgramStack:stack]);
            [self popOperandOffProgramStack:stack];
        }
        
        if ([@"changeSign" isEqualToString:operation] ) {
            NSLog(@"About to change sign in brain");            
            result = [self popOperandOffProgramStack:stack] * -1;
            [self popOperandOffProgramStack:stack];
        }
    }
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

@end
