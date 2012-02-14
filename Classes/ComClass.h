//
//  ComClass.h
//  KXKM
//
//  Created by Snow Leopard User on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VVOSC/VVOSC.h>

@interface ComClass : NSObject {
    
    //ID
    NSString* ipodName;
    
    //PORT & IP
    NSString* udpServerIP;
    int outPort;
	int inPort;
    
    //OSC with VVOSC
    OSCManager	*manager;
    OSCOutPort* vvoscOUT;
    
}

@property (readwrite, retain) NSString* udpServerIP;
@property (readwrite, retain) NSString* ipodName;

@property (readwrite, retain) OSCManager *manager;
@property (readwrite, retain) OSCOutPort *vvoscOUT;

- (NSString *) getIPAddress;
- (void) setIpServer: (NSString *) ipServer;

- (OSCMessage*)oscWithString:(NSString*)msg;
- (NSString*) oscValueToString: (OSCValue*) val;

- (void) receivedOSCMessage: (OSCMessage *)m;
- (void) send: (NSString *) m;

- (void) sayAllo;
- (void) sendInfo;
- (void) sendSync;
- (void) sendSOS;
- (void) sendError: (NSString *) m;
- (void) sendDebug: (NSString *) s;

@end
