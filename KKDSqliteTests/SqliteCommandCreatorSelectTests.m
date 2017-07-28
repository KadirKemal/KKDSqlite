//
//  SqliteCommandCreatorSelectTests.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SqliteCommandCreator.h"
#import "SqliteCommandHelper.h"

#import "SqliteTestData.h"

@interface SqliteCommandCreatorSelectTests : XCTestCase

@end

@implementation SqliteCommandCreatorSelectTests

- (void)testCreatingSelectCommandWithoutParameter {
    NSString *tableName = @"tableName";
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createSelectComand:tableName andParameters:nil];
    NSString *expectedResult = @"SELECT * FROM tableName WHERE 1 = 1";
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == 0, @"parameters should be empty");
    
}

- (void)testCreatingSelectCommandWithParameter {
    NSString *tableName = @"tableName";
    NSDictionary *params = @{@"id" : @3};
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createSelectComand:tableName andParameters:params];
    NSString *expectedResult = @"SELECT * FROM tableName WHERE 1 = 1 AND id = ?";
    
    XCTAssertTrue([expectedResult isEqualToString:commandHelper.rawCommand],
                  @"Strings are not equal %@ - %@", expectedResult, commandHelper.rawCommand);
    
    XCTAssertTrue(commandHelper.parameters.count == 1);
    
    NSString *value = [commandHelper.parameters objectAtIndex:0];
    XCTAssertTrue([value isEqualToString:@"3"]);
}


@end
