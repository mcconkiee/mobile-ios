//
//  GalleryViewController.m
//  OpenPhoto
//
//  Created by Patrick Santana on 11/07/11.
//  Copyright 2012 OpenPhoto
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GalleryViewController.h"

@interface GalleryViewController()
- (void) loadImages;
-(void)_batch:(id)sender;
-(void)_onEdit:(id)sender;
@end

@implementation GalleryViewController
@synthesize service=_service, tagName=_tagName;

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor blackColor];
        self.tabBarItem.image=[UIImage imageNamed:@"tab-gallery.png"];
        self.tabBarItem.title=@"Gallery";
        self.title=@"Gallery";
        self.hidesBottomBarWhenPushed = NO;
        self.wantsFullScreenLayout = YES;
        self.statusBarStyle = UIStatusBarStyleBlackOpaque;
        
        self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundUpload.png"]];
        
        
        // create service and the delegate
        self.service = [[WebService alloc]init];
        [self.service setDelegate:self];
        
        
        NSArray *photos = [PhotoModel getPhotosInManagedObjectContext:[AppDelegate managedObjectContext]];
        
        if (photos == nil || [photos count] == 0){
            self.photoSource = [[[PhotoSource alloc]
                                 initWithTitle:@"Gallery"
                                 photos:nil size:0 tag:nil] autorelease];
        }else {
            self.photoSource = [[[PhotoSource alloc]
                                 initWithTitle:@"Gallery"
                                 photos:photos size:[photos count] tag:nil] autorelease];
        }
        
        // clean table when log out    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(eventHandler:)
                                                     name:kNotificationLoginNeeded       
                                                   object:nil ];
    }
    return self;
}

- (id) initWithTagName:(NSString*) tag{
    self = [self init];
    if (self) {
        self.tagName = tag;
        self.photoSource = [[[PhotoSource alloc]
                             initWithTitle:@"Gallery"
                             photos:nil size:0 tag:nil] autorelease];
    }
    return self;
}

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo 
{
    if (_batchProcess) {
        UIImageView *cmIview;
        
        int idx = [photo index]%4;//zero index of 4 possiblie image views
        UIView *thumbView = [[[[cell subviews] objectAtIndex:0] subviews] objectAtIndex:idx];
        
        if ([_batchPhotos containsObject:photo]) {
            [_batchPhotos removeObject:photo];
            cmIview = (UIImageView*)[thumbView viewWithTag:100];
            [cmIview removeFromSuperview];
        }else {
            [_batchPhotos addObject:photo];
            UIImage *checkmark = [UIImage imageNamed:@"batch_selected.png"];
            cmIview = [[UIImageView alloc] initWithImage:checkmark];
            [cmIview setTag:100];
            [thumbView addSubview:cmIview];
            [cmIview release];
        }
        NSLog(@"_batchphotos: %@",_batchPhotos);
    }else
    {
        if (_batchPhotos)[_batchPhotos removeAllObjects];
        [super thumbsTableViewCell:cell didSelectPhoto:photo];
    }
    
    
}
-(UIBarButtonItem*)refreshButton
{
    UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                    target:self 
                                                                                    action:@selector(loadImages)] autorelease];              
    return refreshButton;
}


-(UIBarButtonItem*)editButton:(BOOL)hasOnState;
{
    UIImage *editImage_state =nil;
    if (hasOnState) {
        editImage_state = [UIImage imageNamed:@"batch_onstate.png"];
    }else {
        editImage_state = [UIImage imageNamed:@"batch_offstate.png"];
    }
    UIButton *eButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eButton setFrame:CGRectMake(0, 0, 30, 30)];
    [eButton setImage:editImage_state forState:UIControlStateNormal];
    [eButton addTarget:self action:@selector(_batch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithCustomView:eButton] autorelease];
    return editButton;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    UIBarButtonItem *refreshButton = [self refreshButton];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    UIBarButtonItem *batchButton = [self editButton:_batchProcess];
    self.navigationItem.leftBarButtonItem = batchButton;

    
    [self loadImages];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)_onEdit:(id)sender
{
//    BatchPhotoViewController *batchVC = [[BatchPhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
//    [self.navigationController pushViewController:batchVC animated:YES];
//    [batchVC release];
}

//toggle the batch state and ui
-(void)_batch:(id)sender
{
    _batchProcess = !_batchProcess;      
    if (_batchProcess) {
        self.title = @"Batch Mode";
        if (_batchPhotos!=nil) {
            [_batchPhotos release];
            _batchPhotos = nil;
        }
        _batchPhotos = [[NSMutableArray alloc] init];
    }else {
        self.title = @"Gallery";
    }
    UIBarButtonItem *leftbutton = [self editButton:_batchProcess];
    self.navigationItem.leftBarButtonItem = leftbutton;
}

- (void) loadImages{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Loading";
    
    if (self.tagName != nil){
        [self.service loadGallery:24 withTag:self.tagName onPage:1];
    }else{
        [self.service loadGallery:24 onPage:1];
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the tile of the table
    self.title=@"Gallery";
    _batchProcess = NO;
}

// delegate
-(void) receivedResponse:(NSDictionary *)response{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    // check if message is valid
    if (![WebService isMessageValid:response]){
        NSString* message = [WebService getResponseMessage:response];
        NSLog(@"Invalid response = %@",message);
        
        // show alert to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    NSArray *responsePhotos = [response objectForKey:@"result"] ;
    
    // result can be null
    if ([responsePhotos class] != [NSNull class]) {
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        BOOL first=YES;
        int totalRows=0;
        
        // Load in core data
        [PhotoModel getPhotosFromOpenPhotoService:responsePhotos inManagedObjectContext:[AppDelegate managedObjectContext]]; 
        
        for (NSDictionary *photo in responsePhotos){
            
            // for the first, get how many pictures is in the server
            if (first == YES){
                totalRows = [[photo objectForKey:@"totalRows"] intValue];
                first = NO;
            }
            
            // Get title of the image
            NSString *title = [photo objectForKey:@"title"];
            if ([title class] == [NSNull class])
                title = @"";
            
#ifdef DEVELOPMENT_ENABLED      
            NSLog(@"Photo Thumb url [%@] with title [%@]", [photo objectForKey:@"path200x200"], title);
#endif            
            
            float width = [[photo objectForKey:@"width"] floatValue];
            float height = [[photo objectForKey:@"height"] floatValue];
            
            // calculate the real size of the image. It will keep the aspect ratio.
            float realWidth = 0;
            float realHeight = 0;
            
            if(width/height >= 1) { 
                // portrait or square
                realWidth = 640;
                realHeight = height/width*640;
            } else { 
                // landscape
                realHeight = 960;
                realWidth = width/height*960;
            }
            
            [photos addObject: [[[Photo alloc]
                                 initWithURL:[NSString stringWithFormat:@"%@", [photo objectForKey:@"path640x960"]]
                                 smallURL:[NSString stringWithFormat:@"%@",[photo objectForKey:@"path200x200"]] 
                                 size:CGSizeMake(realWidth, realHeight) caption:title page:[NSString stringWithFormat:@"%@",[photo objectForKey:@"url"]] ] autorelease]];
        } 
        
        
        if (totalRows != 0){
            self.photoSource = [[[PhotoSource alloc]
                                 initWithTitle:@"Gallery"
                                 photos:photos size:totalRows tag:self.tagName] autorelease] ;
        }
        
        [photos release];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Gallery Loaded"];
#endif
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

- (void) notifyUserNoInternet{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // problem with internet, show message to user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet error" message:@"Couldn't reach the server. Please, check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (void) eventHandler: (NSNotification *) notification{
#ifdef DEVELOPMENT_ENABLED    
    NSLog(@"###### Event triggered: %@", notification);
#endif
    
    if ([notification.name isEqualToString:kNotificationLoginNeeded]){
        self.photoSource = [[[PhotoSource alloc]
                             initWithTitle:@"Gallery"
                             photos:nil size:0 tag:nil] autorelease];
    }
}



- (void) dealloc {
    
    [self.service release];
    [self.tagName release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
