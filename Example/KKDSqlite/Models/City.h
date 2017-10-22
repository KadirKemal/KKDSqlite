//
//  City.h
//  KKDSqlite_Example
//
//  Created by Kadir Kemal Dursun on 22/10/2017.
//  Copyright © 2017 kadirkemal. All rights reserved.
//

#import "SqliteBaseData.h"

@interface City : SqliteBaseData

@property (nonatomic) NSString* name;
@property (nonatomic) int countryId;

@end
