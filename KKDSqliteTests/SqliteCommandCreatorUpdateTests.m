//
//  SqliteCommandCreatorUpdateTests.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SqliteCommandCreator.h"
#import "SqliteCommandHelper.h"

@interface SqliteCommandCreatorUpdateTests : XCTestCase

@end

@implementation SqliteCommandCreatorUpdateTests

- (void)testCreatingUpdateCommandWithoutParameter {
    NSString *tableName = @"tableName";
    NSDictionary *columnValues = @{@"columnName" : @171, @"columnName2" : @"istanbul"};
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createUpdateComand:tableName andColumnValues:columnValues andParameters:nil];
    NSString *expectedResult = @"UPDATE tableName SET columnName = ?, columnName2 = ? WHERE 1 = 1";
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == columnValues.count);
}

- (void)testCreatingUpdateCommandWithParameters {
    NSString *tableName = @"tableName";
    NSDictionary *columnValues = @{@"columnName" : @171, @"columnName2" : @"istanbul"};
    NSDictionary *parameters = @{@"parameter" : @25};
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createUpdateComand:tableName andColumnValues:columnValues andParameters:parameters];
    NSString *expectedResult = @"UPDATE tableName SET columnName = ?, columnName2 = ? WHERE 1 = 1 AND parameter = ?";
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == columnValues.count + parameters.count);
}


@end
