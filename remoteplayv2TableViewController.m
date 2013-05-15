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
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (displaySEC[section]) {
		listSections = [[NSMutableArray arrayWithObjects: nil] retain];
        
        for (NSString *movie in movies)
        {
            NSString *c = [[movie componentsSeparatedByString:@"_"] objectAtIndex:0];
            if ([[sections objectAtIndex:section] isEqualToString:c]) [listSections addObject:[movie copy]];
        }
        
        return [listSections count];
        
	} else {
		///we just want the header cell
        return 0;
	}
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *identity = @"MainCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identity] autorelease];
    }
    
    listSections = [[NSMutableArray arrayWithObjects: nil] retain];
    
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
    
        cell.textLabel.text = [@"        " stringByAppendingString:[[label componentsSeparatedByString:@"."] objectAtIndex:0]];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)] autorelease]; // x,y,width,height
    
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reportButton.frame = CGRectMake(0, 0, 320.0, 52.0); // x,y,width,height
    [reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (!displaySEC[section]) reportButton.backgroundColor = [UIColor blackColor];
    else reportButton.backgroundColor = [UIColor grayColor];
    [reportButton setTitle:[sections objectAtIndex:section] forState:UIControlStateNormal];
    [reportButton addTarget:self
                     action:@selector(buttonPressed:)
           forControlEvents:UIControlEventTouchDown];
    reportButton.tag = section;
    reportButton.titleLabel.textColor = [UIColor whiteColor];
    reportButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    reportButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    reportButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 17.0];
    [reportButton.layer setBorderWidth:2.0f];
    [reportButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [headerView addSubview:reportButton];
    return headerView;
}

- (IBAction) buttonPressed:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    displaySEC[clicked.tag] = !displaySEC[clicked.tag];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:clicked.tag] withRowAnimation:UITableViewRowAnimationFade];
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
        
        NSString *m = [listSections objectAtIndex:(indexPath.row)];
        [appDelegate disableStreaming];
        [appDelegate.moviePlayer load:m];
        [appDelegate.moviePlayer play];
        [appDelegate.interFace setMode:MANU];
        [appDelegate.checkMachine userAct:TIMER_CHECK_USER];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder:aDecoder];
    [self initWithStyle:UITableViewStylePlain];
    //self.view.backgroundColor = [UIColor grayColor];
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
