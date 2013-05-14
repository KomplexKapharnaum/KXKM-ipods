//
//  remoteplayv2TableViewController.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle and Thomas Bohl
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>

@interface remoteplayv2TableViewController : UITableViewController {
    BOOL displaySEC[200];
}

@property (readwrite,retain) IBOutlet UITableView *moviesTable;
@property (readwrite,retain) NSArray *movies;
@property (readwrite,retain) NSMutableArray *sections;
@property (readwrite,retain) NSMutableArray *listSections;

@end
