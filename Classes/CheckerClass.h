//
//  CheckerClass.h
//  KXKM
//
//  Created by Snow Leopard User on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckerClass : NSObject {
    
    NSTimer *timerChecker;
    
}

- (void) start;
- (void) beat;

@end
