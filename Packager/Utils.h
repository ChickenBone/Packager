//
//  Utils.h
//  Packager
//
//  Created by Conor Byrne on 10/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstallUtils : NSObject
@property (strong, nonatomic) id someProperty;
- (void) inject:(NSString*)path;
- (void) killsb;
@end
