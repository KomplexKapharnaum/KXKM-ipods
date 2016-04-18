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

@synthesize docPath;

//###########################################################
// INIT

- (id) init
{
    //les vidéos sont dorénavent a placer dans le dossier Documents de l'App KXKM
    //ne pas activer icloud sous peine de synchronisation des vidéos (ralentissement)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    docPath = [[paths objectAtIndex:0] copy];
    
    //simulator path (dev only)
    if ([[self platform] isEqualToString:@"i386"] || [[self platform] isEqualToString:@"x86_64"]) docPath = @"/Users/kxkm/Desktop/REGIE/_VID/DNC/";
    
    //make list
    [self mediaList];
    
    return [super init];
}

//###########################################################
// UTILITIES

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    if (machine!=nil)
    {
        NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
        return platform;
    }
    return @"ipod";
}

//###########################################################
// FILES MANAGER

//MEDIA list
- (NSArray *)list{
    
    //list compatible video files
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:nil];
    NSArray *extensionsMovies = [NSArray arrayWithObjects:@"mp4", @"mov", @"m4v", nil];
    NSArray *mLmovies = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensionsMovies]];
    
    //list compatible sound files
    NSArray *extensionsSounds = [NSArray arrayWithObjects:@"mp3", @"aif", @"aac", nil];
    NSArray *mLsounds = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensionsSounds]];
    
    //remove DUB sounds (same filename)
    NSMutableArray *mL = [mLmovies mutableCopy];
    NSString *soundname;
    for (id sound in mLsounds) {
        soundname = [sound stringByDeletingPathExtension];
        BOOL isDub = FALSE;
        for (id movie in mLmovies) isDub = isDub || [[movie stringByDeletingPathExtension] isEqualToString:soundname];
        if (!isDub) [mL addObject:sound];
    }
    
    return [mL copy];
}

//UPDATE MEDIA LIST
- (NSArray *) mediaList
{
    //make list
    mediaList = [[self list] copy];
    return mediaList;
}

//SEARCH A MEDIA
- (BOOL) find:(NSString *) file {
    
    if ([mediaList count] > 0)
        if ([mediaList containsObject:file]) return YES;
    
    
    return NO;
}

//SEARCH NEXT MEDIA
- (NSString *) after:(NSString *) file {
    
    if ([self find:file]) {
        int index = [mediaList indexOfObject:file]+1;
        if (index < [mediaList count]) return [mediaList objectAtIndex:index];
    }
    
    return nil;
}

//SEARCH PREVIOUS MEDIA
- (NSString *) before:(NSString *) file {
    
    if ([self find:file]) {
        int index = [mediaList indexOfObject:file]-1;
        if (index >= 0) return [mediaList objectAtIndex:index];
    }
    
    return nil;
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
        //NSLog(@"local file %@",file);
        return myURL;
    }
    
    //REMOTE FILE
    else {
        path=file;
        myURL = [NSURL URLWithString:path];
        
    }
    return myURL;
}

//GET SRT
//RETURN LOCAL URL of found SRT
- (NSURL*) srtfor:(NSString *) file {
    
    NSString* path;
    
    file = [[file stringByDeletingPathExtension] stringByAppendingString:@".srt"];
    path = [docPath stringByAppendingString:@"/"];
    path = [path stringByAppendingString:file];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    
    return [NSURL fileURLWithPath:path];
}

//GET AUDIO DUB
//RETURN LOCAL URL of found SRT
- (NSURL*) dubfor:(NSString *) file {
    
    NSString* path;
    
    if ([[file pathExtension] isEqualToString:@"mp3"]) return nil;
    
    file = [[file stringByDeletingPathExtension] stringByAppendingString:@".mp3"];
    path = [docPath stringByAppendingString:@"/"];
    path = [path stringByAppendingString:file];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    
    return [NSURL fileURLWithPath:path];
}

//MAKE URL
- (NSURL*) urlnew:(NSString *) file {
    
    NSURL* myURL;
    NSString* path;
    
    //LOCAL FILE
    path = [docPath stringByAppendingString:@"/"];
    path = [path stringByAppendingString:file];
    myURL = [NSURL fileURLWithPath:path];
    return myURL;
}

@end
