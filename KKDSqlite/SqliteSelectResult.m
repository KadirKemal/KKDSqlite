//
//  SqliteSelectResult.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import "SqliteSelectResult.h"

@implementation SqliteSelectResult

-(instancetype)init{
    self = [super init];
    if(self){
        _arrResults = [[NSMutableArray alloc] init];
        _arrColumnNames = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
