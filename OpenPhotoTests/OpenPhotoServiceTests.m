//
//  OpenPhotoServiceTests.m
//  OpenPhoto
//
//  Created by Patrick Santana on 29/03/12.
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
//

#import "OpenPhotoServiceTests.h"

@implementation OpenPhotoServiceTests


// test fetch
-(void) testFetch{
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    if (![[service fetchNewestPhotosMaxResult:5] count] > 0){
        STFail(@"We should have some newest photos");
    }
}

- (void) testCheckPhotoOnServer{
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    if ([service isPhotoAlreadyOnServer:@"asdfasdfasdflasfd67786a"])
        STFail(@"Photo should not exist");
 
    if (![service isPhotoAlreadyOnServer:@"bfdf353630e91bab5647dba3b7d44a9bc9305588"])
        STFail(@"Photo should exist");
    
}

// test upload form
-(void) testUploadPhoto{
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    
    NSArray *keys = [NSArray arrayWithObjects: @"title", @"permission",@"tags",nil];
    NSArray *objects = [NSArray arrayWithObjects:@"", [NSNumber numberWithBool:YES], @"", nil];   
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    // load a test image
    NSString *filePath = [[NSBundle bundleForClass:[OpenPhotoServiceTests class]] pathForResource:@"unit_test_image"  ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];  
    
    // send image
    @try {
        [service uploadPicture:data metadata:values fileName:@"unit_test.jpg"];
        STFail(@"It should fail");
    }
    @catch (NSException *exception) {
    }
    
}

// test upload form
-(void) testBatchEditPhotos{
    OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
    NSArray *photos = [service fetchNewestPhotosMaxResult:3];
    if (![photos count] > 0){
        STFail(@"We should have some newest photos");
    }
    
    NSMutableArray *curPhotos = [NSMutableArray array];
    for (int b=0; b<[photos count]; b++) {
        NSMutableDictionary *photo = [NSMutableDictionary dictionaryWithDictionary:[photos objectAtIndex:b]];
        [photo setValue:@"Test,Island,Etc" forKey:@"tags"];
        [photo setValue:@"0" forKey:@"permission"];//test non public
        [photo setValue:[NSString stringWithFormat:@"Test Photo %d",b]
                 forKey:@"title"];
        [curPhotos addObject:photo];
    }

    
    NSArray *responses = [service batchEdit:curPhotos];
    STAssertTrue([responses count]==3,@"should have 3 responses");
    STAssertTrue([[[responses objectAtIndex:2]
                   valueForKeyPath:@"result.title"]
                  isEqualToString:@"Test Photo 2"],@"title should be 'Test Photo 2'");
}

@end
