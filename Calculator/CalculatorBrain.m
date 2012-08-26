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
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (BOOL)isOperation:(NSString *)item;
- (void)pushOperand:(double)operand;
+ (double)popOperandOffProgramStack:(NSMutableArray *)stack;


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
    NSLog(@"Describing program %@", program);
    NSString *result;
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    result = [[NSString alloc]initWithString:[self descriptionOfTopOfStack:stack]];
    NSLog(@"Description: %@", result);
    return result;
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *result = @"0";
    
    id topOfStack = stack.lastObject;
    if (topOfStack) {
        [stack removeLastObject];
    }
    /*
     if number, set result to number,
     if vaiable, set result to variable,
     if no-operand operation, set result to no-operand operation
     if only item in stack, return result.
     if not in the middle of two operand operation, return result.
    
     
     */
     
    
    
    if ([topOfStack isKindOfClass:[NSNumber class]] ||
        [self isVariable:topOfStack] ||
        [self isNoOperandOpperation:topOfStack]) {
        result = topOfStack;
    }
    
    
    
    if ([singleOperandOperators containsObject:[stack objectAtIndex:-1]]) {
        // if top of stack is a a single-operand operation, return the top of the stack, followed by an open parenthesis.
        return [NSString stringWithFormat:@" %@ ( ",[stack objectAtIndex:-1]];
    }
    else if ([twoOperandOperators containsObject:[stack objectAtIndex:-1]]) {
        // if top of stack is a two-operand operation, return the operand with leading and trailing parenthesis.
        return [NSString stringWithFormat:@" ) %@ ( ",[stack objectAtIndex:-1]];
    }
    else
    {
        //  if top of stack is a variable,
        //  a no-operand operation,
        //  or  a number,
        //  return the top of stack
        //        NSSet *variables = [self variablesUsedInProgram:stack];
        //        NSSet *noOperandOperators = [[NSSet alloc]initWithObjects:@"π", nil];
        return [NSString stringWithFormat:@" %@ ",[stack objectAtIndex:-1]];
    }
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
    [self descriptionOfProgram:program];
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSSet *variables = [self variablesUsedInProgram:program];
    
    // Convert variables (nstrings) to nsnumbers using dictionary.
    // Loop through program, if any item in the program array is also the variables set, then replace it with dictionary value or zero if no dictionary value is present.
    for (int i=0; i <= [stack count]; i++) {
        if ([variables containsObject:[stack objectAtIndex:i]]) {
            if ([variableValues objectForKey:[stack objectAtIndex:i]]) {
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:[stack objectAtIndex:i]]];
            }else{
                [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:0]];
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

+ (BOOL)isVariable:(NSString *)item{
    // This is very elegant.  Instead it should take advantage of + (NSSet *)variablesUsedInProgram:(id)program.
    // But I am not sure how to do that.
    NSSet *variables = [[NSSet alloc]initWithObjects:@"a", @"b", @"x", nil];
    return [variables containsObject:item];
}

+ (BOOL)isSingleOperandOperator:(NSString *)item{
    NSSet *singleOperandOperators = [[NSSet alloc]initWithObjects:@"Sqrt", @"Sin", @"Cos", nil];
    return [singleOperandOperators containsObject:item];
}

+ (BOOL)isNoOperandOpperation:(NSString *)item{
    NSSet *noOperandOperators = [[NSSet alloc] initWithObjects:@"π", nil];
    return [noOperandOperators containsObject:item];
}

+ (BOOL)isTwoOperandOperator:(NSString *)item{
    NSSet *twoOperandOperators = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    return [twoOperandOperators containsObject:item];
}
@end
