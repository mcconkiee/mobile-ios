//
//  GalleryViewController.h
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

#include <Three20/Three20.h>
#import "PhotoSource.h"
#import "WebService.h"
#import "OpenPhotoTTThumbsViewController.h"
#import "PhotoModel+OpenPhoto.h"
#import "MBProgressHUD.h"

@class PhotoSet;



@interface GalleryViewController : OpenPhotoTTThumbsViewController <WebServiceDelegate>{
    WebService* service;
    NSString *tagName;
    

    BOOL _batchProcess;
    NSMutableArray *_batchPhotos;
}

@property (nonatomic, retain) WebService *service;
@property (nonatomic, copy) NSString *tagName;

// methods
- (id) initWithTagName:(NSString*) tag;

@end
