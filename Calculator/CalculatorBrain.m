//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Scott Brenner on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *operandStack;

@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

-(NSMutableArray *)operandStack{
    // Lazilly instatiate the operandStack
    if (!_operandStack) {
        _operandStack = [[NSMutableArray alloc]init];
    }
    return _operandStack;
}

-(void) pushOperand:(double)operand{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.operandStack addObject:operandObject];
//    NSLog(@"pushed operand %@", operandObject);
//    NSLog(@"The stack= %@", self.operandStack);
}

-(double) popOperand{
    // Get the last operand and remove it from the stack
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) {
        [self.operandStack removeLastObject];
    }
    NSLog(@"The stack= %@", self.operandStack);
    return [operandObject doubleValue];
}

-(double) performOperation:(NSString *)operation{
    double result = 0;
    NSLog(@"The operation: %@", operation);
    
    // perform operation here, store answer in result
    if( [operation isEqualToString:@"+"]){
        result = [self popOperand] + [self popOperand];
    }
    
    if ([@"*" isEqualToString:operation]) {
        result = [self popOperand] * [self popOperand];
    }

    if ([@"C" isEqualToString:operation]) {
        [self clearStack];
        result = 0;
    }

    if ([@"/" isEqualToString:operation]) {
        double divisor = [self popOperand];
        NSLog(@"dividing by: %g", divisor);
        result = [self popOperand] / divisor;
    }
    
    if ([@"-" isEqualToString:operation]) {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
    }

    if ([@"π" isEqualToString:operation] ) {
        result=M_PI;
    }
    
    if ([@"Sin" isEqualToString:operation] ) {
        result = sin([self popOperand]);
    }
    
    if ([@"Cos" isEqualToString:operation] ) {
        result = cos([self popOperand]);
    }

    if ([@"Sqrt" isEqualToString:operation] ) {
        double target = [self popOperand];
        if (target >0) {
            result = sqrt(target);
        }
    }

    if ([@"changeSign" isEqualToString:operation] ) {
        NSLog(@"About to change sign in brain");
        //    NSLog(@"The stack= %@", self.operandStack);
        double temp = [self popOperand];
        result = -1 * temp;
        NSLog(@"Just changed sign in brain %f", result);
    }
    
    [self pushOperand:result];  // put the result on the stack
//    NSLog(@"The stack= %@", self.operandStack);
    return result;
}

-(void) clearStack{
    [self.operandStack removeAllObjects];
}

@end
