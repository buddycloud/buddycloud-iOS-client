//
//  SettingsViewController.m
//  Buddycloud
//
//  Created by Ross Savage on 4/10/10.
//  Copyright 2010 buddycloud. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditSettingsViewController.h"
#import "EditSettingCell.h"


@implementation SettingsViewController
@synthesize serverTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;


#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    EditSettingCell *cell = (EditSettingCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EditSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch (indexPath.row) {
		case 0:
//			[cell setText:NSLocalizedString(@"Servername", @"")];
			[cell setTextFieldToEdit:self.serverTextField];
			//			[[cell contentView] addSubview:self.serverTextField];
			break;
		case 1:
			[cell setText:NSLocalizedString(@"Username", @"")];
			break;
		case 2:
			[cell setText:NSLocalizedString(@"Password", @"")];
			break;
			
		default:
			break;
	}
    // Configure the cell...
    
    return cell;
}

- (void) setupTextFields
{
    self.serverTextField = [self createTextField];
    self.serverTextField.returnKeyType = UIReturnKeyNext;
    self.serverTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.serverTextField.placeholder = NSLocalizedString(@"<enter text here>",@"");
    
    // have a next button on the keyboard instead of return
    self.usernameTextField = [self createTextField];
    self.usernameTextField.placeholder = NSLocalizedString(@"<enter text here>",@"");
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameTextField.returnKeyType = UIReturnKeyNext;
    
    self.passwordTextField = [self createTextField];
    self.passwordTextField.placeholder = NSLocalizedString(@"<password>", @"Placeholder in new server view");
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.secureTextEntry = YES;
}

- (UITextField *) createTextField
{    
    UITextField *returnTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    returnTextField.textColor = [UIColor blackColor];
    returnTextField.font = [UIFont systemFontOfSize:16.0f];
    returnTextField.opaque = YES;
    returnTextField.placeholder = NSLocalizedString(@"<enter text here>", @"");
    returnTextField.backgroundColor = [UIColor whiteColor];
    returnTextField.adjustsFontSizeToFitWidth = YES;
    returnTextField.enablesReturnKeyAutomatically = YES;
    returnTextField.keyboardType = UIKeyboardTypeASCIICapable;    // use the default type input method (entire keyboard)
    returnTextField.returnKeyType = UIReturnKeyDone;
    returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;    // has a clear 'x' button to the right
    return [returnTextField autorelease];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//	EditSettingsViewController *detailViewController = nil;
//	switch (indexPath.row) {
//		case 0:
//			detailViewController = [[EditSettingsViewController alloc] initWithSettingName:NSLocalizedString(@"Servername", @"")];
//			break;
//		case 1:
//			detailViewController = [[EditSettingsViewController alloc] initWithSettingName:NSLocalizedString(@"Username", @"")];
//
//			break;
//		case 2:
//			detailViewController = [[EditSettingsViewController alloc] initWithSettingName:NSLocalizedString(@"Password", @"")];
//
//			break;
//			
//		default:
//			break;
//	}
//	 [self.navigationController pushViewController:detailViewController animated:YES];
//	 [detailViewController release];
//}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

