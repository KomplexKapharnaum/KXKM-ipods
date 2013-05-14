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
    
    moviesTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    return [super init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return [self.sections count];	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
	return [sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (displaySEC[section]) {
		listSections = [[NSMutableArray arrayWithObjects: nil] retain];
        
        for (NSString *movie in movies)
        {
            NSString *c = [[movie componentsSeparatedByString:@"_"] objectAtIndex:0];
            if ([[sections objectAtIndex:section] isEqualToString:c]) [listSections addObject:[movie copy]];
        }
        
        return ([listSections count]+1);
        
	} else {
		///we just want the header cell
		return 1;
	}
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *identity = @"MainCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identity] autorelease];
    }
    
    listSections = [[NSMutableArray arrayWithObjects: nil] retain];
    
    //add header
    [listSections addObject:[sections objectAtIndex:indexPath.section]];
    
    //list films
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
    
    //header
    if (indexPath.row == 0)
        if (displaySEC[indexPath.section]) cell.textLabel.text = @"-";
        else cell.textLabel.text = @"+";
    
    //ajout du film à la liste
	else
        cell.textLabel.text = [@"        " stringByAppendingString:[[label componentsSeparatedByString:@"."] objectAtIndex:0]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:83/255.0f green:110/255.0f blue:245/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    else cell.textLabel.textColor = [UIColor blackColor];
}

//selection de la case -> lecture du film
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    remoteplayv2AppDelegate *appDelegate = (remoteplayv2AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Header clicked (toggle section)
    if (indexPath.row == 0)
    {
		///it's the first row of any section so it would be your custom section header
        
		///put in your code to toggle your boolean value here
		displaySEC[indexPath.section] = !displaySEC[indexPath.section];
        
		///reload this section
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
	}
    //Movie selected
    else
    {
        listSections = [[NSMutableArray arrayWithObjects: nil] retain];
        for (NSString *movie in movies)
        {
            NSString *c = [[movie componentsSeparatedByString:@"_"] objectAtIndex:0];
            if ([[sections objectAtIndex:indexPath.section] isEqualToString:c]) [listSections addObject:[movie copy]];
        } 
        
        NSString *m = [listSections objectAtIndex:(indexPath.row-1)];
        [appDelegate disableStreaming];
        [appDelegate.moviePlayer load:m];
        [appDelegate.moviePlayer play];
        [appDelegate.interFace setMode:MANU];
        [appDelegate.checkMachine userAct:TIMER_CHECK_USER];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder:aDecoder];
    [self initWithStyle:UITableViewStylePlain];
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    moviesTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
