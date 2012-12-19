//
//  FilesClass.h
//  KXKM
//
//  Created by Snow Leopard User on 09/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilesClass : NSObject {
    
    NSString *docPath;
    NSArray *mediaList;
    
}

@property (readwrite, retain) NSString* docPath;

- (NSString *) platform;

- (NSArray *) list;
- (NSArray *) mediaList;
- (BOOL) find:(NSString *) file;
- (NSString *) after:(NSString *) file;
- (NSString *) before:(NSString *) file;
- (NSURL*) url:(NSString *) file;
- (NSURL*) urlnew:(NSString *) file;

@end
