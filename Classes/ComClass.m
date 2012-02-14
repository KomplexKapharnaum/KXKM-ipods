//
//  ComClass.m
//  KXKM
//
//  Created by Snow Leopard User on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ComClass.h"
#import "remoteplayv2AppDelegate.h"

@implementation ComClass

@synthesize manager, udpServerIP, vvoscOUT, ipodName;

//###########################################################
// INIT & OPEN PORTS

- (id) init
{
    //IPOD NAME
    ipodName = [[NSUserDefaults standardUserDefaults] stringForKey:@"osc_id_name_key"];
    
    //COMMON UDP
    inPort = [[[NSUserDefaults standardUserDefaults] stringForKey:@"osc_port_in_key"] intValue];
    outPort = [[[NSUserDefaults standardUserDefaults] stringForKey:@"osc_port_server_key"] intValue];
    udpServerIP = [[NSUserDefaults standardUserDefaults] stringForKey:@"osc_ip_server_key"];
    
    //VVOSC Communication (UDP)
    //MANAGER add osc manager object
    manager = [[OSCManager alloc] init];
    [manager setDelegate:self];    
	
    //INPUT create an input port for receiving OSC data
    [manager createNewInputForPort:inPort];
	
    //OUTPUT create outPort to the server
    vvoscOUT= [manager createNewOutputToAddress:udpServerIP atPort:outPort];
    
    
    return [super init];	
}

//###########################################################
// UTILITIES

- (NSString *) getIPAddress{
    NSArray *addresses = [[NSHost currentHost] addresses];
    NSString * ip;
    for (NSString *anAddress in addresses) {
        if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
            ip = anAddress;
            break;
        } 
        else ip = @"No Wifi !";
    }
	return ip;
}

- (void) setIpServer: (NSString *) ipServer {
    [manager deleteAllOutputs];
    udpServerIP = [ipServer copy];
    vvoscOUT= [manager createNewOutputToAddress:udpServerIP atPort:outPort];
}

//###########################################################
// OSC TOOLS

// STRING to OSC
-(OSCMessage*)oscWithString:(NSString*)msg{
    NSArray *words = [msg componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    OSCMessage *oscmsg = [OSCMessage createWithAddress:[@"/" stringByAppendingString: ipodName]];
    for (int y = 0; y < [words count]; y++) [oscmsg addString:[words objectAtIndex:y]];
    return oscmsg;
}

// OSC to STRING
- (NSString*) oscValueToString: (OSCValue*) val {
    switch (val.type)   {
        case OSCValInt:
            return [NSString stringWithFormat:@"%ld",[val intValue]];
        case OSCValFloat:
            return  [NSString stringWithFormat:@"%f",[val floatValue]];
        case OSCValString:
            return [val stringValue];
        case OSCVal64Int:
            return [NSString stringWithFormat:@"%qi",[val longLongValue]];
            break;
        case OSCValDouble:
            return [NSString stringWithFormat:@"%f",[val doubleValue]];
        case OSCValChar:
            return [NSString stringWithFormat:@"%c",[val charValue]];
        case OSCValBool:
            if ([val boolValue]) return @"1";
            else if ([val boolValue]) return @"0";
        case OSCValBlob:
            return[[NSString alloc] initWithData:[val blobNSData] encoding:NSUTF8StringEncoding];
        default:
            return @"typeunrecognized";
    }
}

//###########################################################
// OSC COM

// OSC RECEIVER
- (void) receivedOSCMessage: (OSCMessage *) m {
    
    NSString *command = [m address];
    
    if ([m valueCount] == 1) {
        command = [command stringByAppendingString:@" "];
        command = [command stringByAppendingString:[self oscValueToString:[m value]]];
    }
    else if ([m valueCount] > 0) {
        for (int y = 0; y < [m valueCount] ; y++) 
        {            
            command = [command stringByAppendingString:@" "];
            command = [command stringByAppendingString:[self oscValueToString:[m valueAtIndex:y]]];
        }
    }
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.runMachine dispatch:command];
}

//OSC SENDER
- (void) send: (NSString *) m {
    
    //using vvosc
    [vvoscOUT sendThisMessage:[self oscWithString:m]];
}

//###########################################################
// COMMUNICATION

//Say ALLO
-(void) sayAllo{
    [self send:@"allo"];
}

//Info message : IP, media list
-(void) sendInfo{
    
    NSString *msg = @"initinfo ";
    msg = [msg stringByAppendingString:[self getIPAddress]];
    [self send:msg];
    
    //for (NSString *movies in mediaList) 
        //[self sendUDP:[@"fileinfo " stringByAppendingString:movies]];
    
}


//Sync message : send player state message
-(void)sendSync{
    
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Player Mode : Auto, Manu, Streaming, ... 
    NSString* msg = [appDelegate.interFace modeName];
    
    //Player State : waiting, playing,
    msg = [msg stringByAppendingString:@" "];
    
    NSString* movie = [appDelegate.moviePlayer movie];
    
    if (movie == nil) msg = [msg stringByAppendingString:@"stopmovie"];
    else {
            msg = [msg stringByAppendingString:@"playmovie "];
            msg = [msg stringByAppendingString:movie];
            //msg = [msg stringByAppendingString:[NSString stringWithFormat:@" %i",[appDelegate.moviePlayer time]]];
    }
    
    //TODO construct detailed state message 
    //TODO construct detailed state message
    //TODO construct detailed state message
    
    //msg = [msg stringByAppendingString:[NSString stringWithFormat:@" %i",[moviePlayer currentPlaybackTime]]];
    //msg = [msg stringByAppendingString:[NSString stringWithFormat:@" %i",[userViewController isMute]]];
    
    [self send:msg];
}

//send SOS
-(void) sendSOS {    
    [self send:@"sos"];
}

//send ERROR
-(void) sendError:(NSString*)m {    
    [self send:[@"error " stringByAppendingString:m]];
}

- (void) sendDebug : (NSString*) s{
	[self send:[@"debug " stringByAppendingString:s]];
}



@end
