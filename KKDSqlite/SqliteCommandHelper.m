//
//  SqliteCommandHelper.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import "SqliteCommandHelper.h"

@implementation SqliteCommandHelper

-(instancetype)init{
    self = [super init];
    if(self){
        _parameters = [NSMutableArray<NSString *> new];
    }
    return self;
}

@end
