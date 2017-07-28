//
//  SqliteCommandCreatorTests.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SqliteCommandCreator.h"
#import "SqliteCommandHelper.h"

#import "SqliteTestData.h"

@interface SqliteCommandCreatorDeleteTests : XCTestCase

@end

@implementation SqliteCommandCreatorDeleteTests

- (void)testCreatingDeleteCommandWithoutParameter {
    NSString *tableName = @"tableName";
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createDeleteComand:tableName andParameters:nil];
    NSString *expectedResult = @"DELETE FROM tableName WHERE 1 = 1";
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == 0, @"parameters should be empty");
    
}

- (void)testCreatingDeleteCommandWithOneParameter {
    NSString *tableName = @"tableName";
    NSDictionary *params = @{@"id" : @3};
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createDeleteComand:tableName andParameters:params];
    NSString *expectedResult = @"DELETE FROM tableName WHERE 1 = 1 AND id = ?";
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == 1);

    NSString *value = [commandHelper.parameters objectAtIndex:0];
    XCTAssertTrue([value isEqualToString:@"3"]);
}

- (void)testCreatingDeleteCommandWithTwoParameter {
    NSString *tableName = @"tableName";
    NSDictionary *params = @{@"parentId" : @3, @"status" : @"active"};
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createDeleteComand:tableName andParameters:params];
    NSString *expectedResult = @"DELETE FROM tableName WHERE 1 = 1 AND status = ? AND parentId = ?"; //order is important :(
    
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == 2);
    
    NSString *value = [commandHelper.parameters objectAtIndex:0];
    XCTAssertTrue([value isEqualToString:@"active"]);
    
    value = [commandHelper.parameters objectAtIndex:1];
    XCTAssertTrue([value isEqualToString:@"3"]);    
}


- (void) testCreatingDeleteCommandForSqliteBaseData {
    SqliteTestData *data = [SqliteTestData new];
    
    data.id = 55;
 
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createDeleteComand: data];
    NSString *expectedResult = [NSString stringWithFormat: @"DELETE FROM %@ WHERE 1 = 1 AND %@ = ?",
                                SqliteTestData.tableName,
                                data.primaryColumnName];
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == 1);
    
    NSString *value = [commandHelper.parameters objectAtIndex:0];
    
    NSString *expectedID = [NSString stringWithFormat:@"%@", [data primaryColumnValue]];
    XCTAssertTrue([value isEqualToString:expectedID]);
}


@end
