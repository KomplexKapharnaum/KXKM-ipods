//
//  remoteplayv2TableViewController.m
//  remoteplayv2
//
//  Created by Pierre Hoezelle and Thomas Bohl
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import "remoteplayv2TableViewController.h"
#import "remoteplayv2AppDelegate.h"
#import "ConfigConst.h"

@implementation remoteplayv2TableViewController

@synthesize movies,sections,moviesTable,listSections;

- (id) init {
    
    moviesTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    return [super init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return [self.sections count];	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return [sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    listSections = [[NSMutableArray arrayWithObjects: nil] retain];
    
    for (NSString *movie in movies)
    {
        NSString *c = [[movie componentsSeparatedByString:@"_"] objectAtIndex:0];
        if ([[sections objectAtIndex:section] isEqualToString:c]) [listSections addObject:[movie copy]];
    } 
	
	return [listSections count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *identity = @"MainCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identity] autorelease];
    }
    
    listSections = [[NSMutableArray arrayWithObjects: nil] retain];
    for (NSString *movie in movies)
    {
        NSString *c = [[movie componentsSeparatedByString:@"_"] objectAtIndex:0];
        if ([[sections objectAtIndex:indexPath.section] isEqualToString:c]) [listSections addObject:[movie copy]];
    } 
    
    //simplification du nom affiche
    NSString *label;
    NSString *prefix;

    if ([[[listSections objectAtIndex:indexPath.row] componentsSeparatedByString:@"_"] count] > 1) {
        
        prefix = [[[listSections objectAtIndex:indexPath.row] componentsSeparatedByString:@"_"] objectAtIndex:0];
        prefix = [prefix stringByAppendingString:@"_"];
        
        label = [[[listSections objectAtIndex:indexPath.row] componentsSeparatedByString:prefix] objectAtIndex:1];       
    }
    else label = [listSections objectAtIndex:indexPath.row];
    
    //ajout du film à la liste
	cell.textLabel.text = [@"      " stringByAppendingString:[[label componentsSeparatedByString:@"."] objectAtIndex:0]];
	
	return cell;
}

//selection de la case -> lecture du film
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    listSections = [[NSMutableArray arrayWithObjects: nil] retain];
    for (NSString *movie in movies)
    {
        NSString *c = [[movie componentsSeparatedByString:@"_"] objectAtIndex:0];
        if ([[sections objectAtIndex:indexPath.section] isEqualToString:c]) [listSections addObject:[movie copy]];
    } 
    
    NSString *m = [listSections objectAtIndex:indexPath.row];
    [appDelegate disableStreaming];
    [appDelegate.moviePlayer load:m];
    [appDelegate.moviePlayer play];
    [appDelegate.interFace setMode:MANU];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder:aDecoder];
    [self initWithStyle:UITableViewStyleGrouped];
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    moviesTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
