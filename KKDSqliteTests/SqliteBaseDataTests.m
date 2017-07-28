//
//  SqliteBaseDataTests.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SqliteTestData.h"


@interface SqliteBaseDataTests : XCTestCase{
    SqliteTestData *sqliteTestData;
    NSArray *columnNames;
}

@end

@implementation SqliteBaseDataTests

- (void)setUp {
    [super setUp];
    
    sqliteTestData = [SqliteTestData new];
    columnNames = @[@"id", @"aString", @"anotherString", @"aInteger", @"aBool"];
    
    //these are important for db operations
    sqliteTestData.id = 11;
    sqliteTestData.aString = @"istanbul";
    sqliteTestData.anotherString = @"mersin";
    sqliteTestData.aInteger = 77;
    sqliteTestData.aBool = YES;
    
    //these fields should be ignored for db operataions
    sqliteTestData.stringIgnore = @"Ignore";
    sqliteTestData.array = [NSMutableArray new];
}


- (void)testCreatingCreateCommand {
    NSMutableDictionary *dict = sqliteTestData.columnValues;
    
    XCTAssertTrue(dict.count == columnNames.count);
    
    for(NSString *columnName in columnNames){
        id value = [dict objectForKey:columnName];
        XCTAssertTrue(value == [sqliteTestData valueForKey:columnName], "%@ value is incorrect", columnName);
    }
}




@end
