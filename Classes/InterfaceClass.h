//
//  InterfaceClass.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InterfaceClass : NSObject {
    
    int mode;
}

-(void) setMode:(int) md;
-(int) mode;
-(NSString*) modeName;

@end
