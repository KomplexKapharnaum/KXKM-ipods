//
//  remoteplayv2TableViewController.m
//  remoteplayv2
//
//  Created by Pierre Hoezelle, Thomas Bohl, Jeremie Forge
//  Copyright 2011 KXKM. Creative Commons BY-NC-SA.
//

#import "remoteplayv2TableViewController.h"
#import "remoteplayv2AppDelegate.h"

@implementation remoteplayv2TableViewController

@synthesize moviesList,section_list,moviesTable;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // There is only one section.
    return [section_list count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return [section_list objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of time zone names.
    NSInteger count=0;
    for (NSString *movie in moviesList) {
        if([[movie substringToIndex:[[section_list objectAtIndex:section]length]]isEqualToString:[section_list objectAtIndex:section]]){
            count++;
        }
    }
    return count;
}


//dessiner les cases de la liste
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    // Try to retrieve from the table view a now-unused cell with the given identifier.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    // If no cell is available, create a new one using the given identifier.
    if (cell == nil) {
        // Use the default cell style.
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }
    
    // Set up the cell.
    NSString *prefix = [section_list objectAtIndex:indexPath.section];
    NSString *t = @"_";
    NSString *selecteur = [prefix stringByAppendingString:t];
    //NSLog(selecteur);
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",selecteur];
    NSArray *selected_movieList = [moviesList filteredArrayUsingPredicate:pred];
    
    
    NSString *movieName = [selected_movieList objectAtIndex:indexPath.row];
    cell.textLabel.text = movieName;
    
    return cell;
}

//selection de la case -> lecture du film
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *m = [moviesList objectAtIndex:indexPath.row];
    [appDelegate disableStreaming];
    [appDelegate initGoMovieWithName:m];    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    moviesList = [[NSMutableArray alloc] init];
    
    
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [moviesList release];
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
