//
//  SqliteTestData.h
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import "SqliteBaseData.h"

@interface SqliteTestData : SqliteBaseData

@property NSString *aString;
@property NSString *anotherString;
@property int aInteger;
@property BOOL aBool;

@property NSString<DBIgnore>* stringIgnore;
@property NSMutableArray* array;

@end
