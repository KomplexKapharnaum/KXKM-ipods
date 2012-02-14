//
//  InterfaceClass.m
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InterfaceClass.h"
#import "ConfigConst.h"

@implementation InterfaceClass

//###########################################################
// INIT

- (id) init
{
    mode = AUTO;
    return [super init];	
}

//###########################################################
// MODE CTRL

-(void) setMode:(int) md {
    mode = md;
}

-(int) mode {
    return mode;
}

-(NSString*) modeName {
    if (mode == AUTO) return @"auto";
    else if (mode == MANU) return @"manu";
    else return @"unknown";
}

@end
