//
//  BatchPhotoViewController.m
//  OpenPhoto
//
//  Created by Eric McConkie on 4/29/12.
//  Copyright (c) 2012 OpenPhoto. All rights reserved.
//

#import "BatchPhotoViewController.h"

@interface BatchPhotoViewController ()

@end




@implementation BatchPhotoViewController

@synthesize dataSource = _dataSource;




#pragma mark ---------------------------------->> 
#pragma mark -------------->>private
-(void)_ui
{
    [_commitButton setImage:@"" forState:UIControlStateNormal];
    
}

//override for batch edit.....same method name, new actions
- (IBAction)upload:(id)sender {
#ifdef DEVELOPMENT_ENABLED
    NSLog(@"Batch button clicked. Save all details in the database");
#endif
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"commit batch chnages"];
#endif    
    
    
}
#pragma mark ---------------------------------->> 
#pragma mark -------------->>life cycle
-(void)viewWillAppear:(BOOL)animated
{
    self.title = @"Batch Edit";
    [self _ui];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
