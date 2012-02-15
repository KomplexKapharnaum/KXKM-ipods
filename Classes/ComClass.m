//
//  ComClass.m
//  KXKM
//
//  Created by Snow Leopard User on 08/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ComClass.h"
#import "remoteplayv2AppDelegate.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

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
    udpServerIP = [self getIPBroadcast];
    
    //VVOSC Communication (UDP)
    //MANAGER add osc manager object
    manager = [[OSCManager alloc] init];
    [manager setDelegate:self];    
	
    //INPUT create an input port for receiving OSC data
    [manager createNewInputForPort:inPort];
	
    //OUTPUT create outPort to the server
     if ([self verifyIp:udpServerIP])
        vvoscOUT = [manager createNewOutputToAddress:udpServerIP atPort:outPort];
    
    return [super init];	
}

//###########################################################
// UTILITIES

/* DEPRECATED WAY TO OBTAIN IP
- (NSString *) OLDgetIPAddress{
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
}*/

//GET IP
- (NSString *)getIPAddress
{
    NSString *address = @"noIP";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

//GET NET MASK
- (NSString *)getNetMask {
    
    NSString *netmask = @"noMASK";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return netmask;
}

//GET BROADCAST IP
- (NSString *)getIPBroadcast {
    
    NSString *broadcast = @"";
    NSString *str;
    
    NSArray *address = [[self getIPAddress] componentsSeparatedByString:@"."];
    NSArray *netmask = [[self getNetMask] componentsSeparatedByString:@"."];
    
    //TODO BETTER BROADCAST CALCULATION FOR COMPLEX NETMASK NETWORKS and IPv6 networks !!!!
    if (([address count] == 4) && ([netmask count] == 4)) {
        for (int i = 0; i < 4; i ++) {
            
            if ([[netmask objectAtIndex:i] isEqualToString:@"0"]) str = @"255";
            else str = [address objectAtIndex:i];
                
            broadcast = [broadcast stringByAppendingString:str];
            if (i < 3) broadcast = [broadcast stringByAppendingString:@"."];
        }
    }
    else broadcast = @"noSERVER";
    
    return broadcast;
}

- (BOOL) verifyIp: (NSString *) ip {
    return (![ip hasPrefix:@"127"] && [[ip componentsSeparatedByString:@"."] count] == 4);
}

- (void) setIpServer: (NSString *) ipServer {
    
    if ([self verifyIp:ipServer]) {
        [manager deleteAllOutputs];
        udpServerIP = [ipServer copy];
        vvoscOUT= [manager createNewOutputToAddress:udpServerIP atPort:outPort];
    }
}

- (NSString*) serverState {
    
    if ([udpServerIP isEqualToString:@"noSERVER"]) return @"noserver";
    else if ([udpServerIP isEqualToString:[self getIPBroadcast]]) return @"broadcast";
    else return @"ok";
    
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
    
    //Screen alert
    if ([[appDelegate.disPlay resolution] isEqualToString:@"noscreen"]) {
        [self send:@"noscreen"];
        return;
    }
    
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
