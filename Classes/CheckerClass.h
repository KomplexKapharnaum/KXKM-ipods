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
    
    int lastTab;
    int timeHere;
    int batteryRefresh;
}


- (void) start;
- (void) beat;
- (void) userAct: (int) tim;

@end
