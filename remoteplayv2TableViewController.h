//
//  remoteplayv2TableViewController.h
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import <UIKit/UIKit.h>

@interface remoteplayv2TableViewController : UITableViewController {
    
    IBOutlet UITableView *moviesTable;
    //list des fichier présent dans le dossier document de l'app (upload via iexplorer)
    NSArray *moviesList;
    
    NSArray *test;
}

@property (readwrite,retain) IBOutlet UITableView *moviesTable;
@property (readwrite,retain) NSArray *moviesList;
@property (readwrite,retain) NSArray *test;

@end
