//
//  FilesClass.m
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilesClass.h"
#include <sys/sysctl.h>
#import "remoteplayv2AppDelegate.h"

@implementation FilesClass


//###########################################################
// INIT

- (id) init
{
    //les vidéos sont dorénavent a placer dans le dossier Documents de l'App KXKM
    //ne pas activer icloud sous peine de synchronisation des vidéos (ralentissement)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    docPath = [[paths objectAtIndex:0] copy];
    
    //simulator path (dev only)
    if ([[self platform] isEqualToString:@"i386"]) docPath = @"/Media/Video/";
    
    //make list
    mediaList = [[self list] copy];
    
    return [super init];	
}

//###########################################################
// UTILITIES

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

//###########################################################
// FILES MANAGER

//MEDIA list
- (NSArray *)list{
    
    //list compatible video files
    NSArray *extensions = [NSArray arrayWithObjects:@"mp4", @"mov", @"m4v", nil];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:nil];
    NSArray *mL = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensions]];
    
    return mL;
}

//SEARCH A MEDIA
- (BOOL) find:(NSString *) file {
    
    if ([mediaList count] > 0)
        if ([mediaList containsObject:file]) return YES;
    
    
    return NO;
}

//GET URL
//RETURN LOCAL URL or STREAM SERVER URL
- (NSURL*) url:(NSString *) file {
    
    NSURL* myURL;
    NSString* path;
    
    //LOCAL FILE
    if ([self find:file]) {
        path = [docPath stringByAppendingString:@"/"];
        path = [path stringByAppendingString:file];
        myURL = [NSURL fileURLWithPath:path];
        return myURL;
    }
    
    //REMOTE FILE
    else {
        remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        path = @"http://";
        path = [path stringByAppendingString:appDelegate.comPort.udpServerIP];
        path = [path stringByAppendingString:@":8074/"]; //TODO : CONFIGURABLE !!
        path = [path stringByAppendingString:file];
        
        myURL = [NSURL URLWithString:path];
        
    }
    return myURL;
}

@end
