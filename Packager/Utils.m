//
//  Utils.m
//  Packager
//
//  Created by Conor Byrne on 10/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#include "spawn.h"

#define execute(ARGS) \
{\
pid_t _____PID_____;\
posix_spawn(&_____PID_____, ARGS[0], NULL, NULL, (char **)&ARGS, NULL);\
waitpid(_____PID_____, NULL, 0);\
}

@implementation InstallUtils

- (void) inject:(NSString *)path {
    // trustcache
    const char *args[] = {"/var/containers/Bundle/iosbinpack64/usr/bin/inject", path.UTF8String, NULL};
    execute(args);
}

- (void) killsb {
    const char *args[] = {"/var/containers/Bundle/iosbinpack64/usr/bin/killall", "SpringBoard", NULL};
    execute(args)
}

@end
