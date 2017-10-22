//
//  City.m
//  KKDSqlite_Example
//
//  Created by Kadir Kemal Dursun on 22/10/2017.
//  Copyright © 2017 kadirkemal. All rights reserved.
//

#import "City.h"

@implementation City

+(NSString *)tableName{
    return @"Cities";
}

-(void)bindToParent:(SqliteBaseData *)parent{
    _countryId = parent.id;
}

@end
