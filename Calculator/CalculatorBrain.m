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

- (NSMutableArray *)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
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

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
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
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([@"π" isEqualToString:operation] ) {
            result=M_PI;
        } else if ([@"Sin" isEqualToString:operation] ) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([@"Cos" isEqualToString:operation] ) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([@"Sqrt" isEqualToString:operation] ) {
            double target = [self popOperandOffProgramStack:stack];
            if (target >0) {
                result = sqrt(target);
            }
        } else if ([@"changeSign" isEqualToString:operation] ) {
            NSLog(@"About to change sign in brain");
            //    NSLog(@"The stack= %@", self.operandStack);
            double temp = [self popOperandOffProgramStack:stack];
            result = -1 * temp;
            NSLog(@"Just changed sign in brain %f", result);
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

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // Convert variables (nstrings) to nsnumbers using dictionary.
    // Loop through program, if any item the program array is not an NSNumber or an operation, then replace it with dictionary value or zero if no dictioary value is present.
    for (int i=0; i <= [stack count]; i++) {
        // if item in stack is a operation or a number continue, else convert varialbe to number.
        if ([self isOperation:[stack objectAtIndex:i]] || [[stack objectAtIndex:i] isKindOfClass:[NSNumber class]]){
            continue;
        } else {
            if ([variableValues objectForKey:[stack objectAtIndex:i]]) {
                [stack insertObject:[variableValues objectForKey:[stack objectAtIndex:i]] atIndex:i];
            }else{
                [stack insertObject:[NSNumber numberWithDouble:0] atIndex:i];
            }
        }
    }
    
    // run the program and return the result.
    return [self popOperandOffProgramStack:stack];
}

+ (BOOL)isOperation:(NSString *) item
{
    NSSet *operations = [NSSet setWithObjects:@"+",@"-",@"*",@"/",@"Sqrt",@"π",@"Sin", @"Cos", @"changeSign", nil];
    
    return [operations containsObject:item];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    // Assumes any string that isn't an operation is a variable.
    NSMutableSet *theVariables;
    for (int i=0; i <= [program count]; i++) {
        if ([self isOperation:[program objectAtIndex:i]] || [[program objectAtIndex:i] isKindOfClass:[NSNumber class]]){
            continue;
        } else if([[program objectAtIndex:i] isKindOfClass:[NSString class]]){
            [theVariables addObject:[program objectAtIndex:i]];
        }
    }
    
    if ([theVariables count] > 0) {
        return [theVariables copy];
    }else
    {
        return nil;
    }
}

@end
