//
//  SqliteCommandCreatorInsertTests.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SqliteCommandCreator.h"
#import "SqliteCommandHelper.h"

@interface SqliteCommandCreatorInsertTests : XCTestCase

@end

@implementation SqliteCommandCreatorInsertTests

- (void)testCreatingCreateCommand {
    NSString *tableName = @"tableName";
    NSDictionary *columnValues = @{@"columnName" : @171, @"columnName2" : @"istanbul"};
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createCreateComand:tableName andColumnValues:columnValues];
    NSString *expectedResult = @"INSERT INTO tableName (columnName, columnName2) VALUES (?, ?)";
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == columnValues.count);
}

@end
