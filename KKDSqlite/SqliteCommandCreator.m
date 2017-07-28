//
//  SqliteCommandCreator.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import "SqliteCommandCreator.h"

@implementation SqliteCommandCreator

+(SqliteCommandHelper *) createSelectComand:(NSString *) tableName
                              andParameters:(NSDictionary *) parameters{
    return [self createSelectComand:tableName andParameters:parameters andOrderBy:nil];
}

+(SqliteCommandHelper *) createSelectComand:(NSString *) tableName
                              andParameters:(NSDictionary *) parameters
                                 andOrderBy:(NSString*) orderBy{
    
    SqliteCommandHelper *commandHelper = [SqliteCommandHelper new];
    
    NSMutableString *command = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE 1 = 1", tableName];
    
    for(NSString *key in parameters){
        [command appendFormat:@" AND %@ = ?", key];
        [commandHelper.parameters addObject:[NSString stringWithFormat:@"%@", [parameters objectForKey:key]]];
    }
    
    if(orderBy != nil){
        [command appendFormat:@" %@",orderBy];
    }
    
    commandHelper.rawCommand = command;
    return commandHelper;
}

+(SqliteCommandHelper *) createDeleteComand:(NSString *) tableName andParameters:(NSDictionary *) parameters{
    SqliteCommandHelper *commandHelper = [SqliteCommandHelper new];
    
    NSMutableString *command = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE 1 = 1", tableName];
    
    for(NSString *key in parameters){
        [command appendFormat:@" AND %@ = ?", key];
        [commandHelper.parameters addObject:[NSString stringWithFormat:@"%@", [parameters objectForKey:key]]];
    }
    
    commandHelper.rawCommand = command;
    return commandHelper;
}

+(SqliteCommandHelper *) createUpdateComand:(NSString *) tableName
                            andColumnValues:(NSDictionary *) columnValues
                              andParameters:(NSDictionary *) parameters{
    SqliteCommandHelper *commandHelper = [SqliteCommandHelper new];
    
    NSMutableString *newValueString = [NSMutableString string];
    
    for (NSString* key in columnValues) {
        id value = [columnValues objectForKey:key];
        [newValueString appendFormat:@", %@ = ?", key];
        
        [commandHelper.parameters addObject:[NSString stringWithFormat:@"%@", value]];
    }
    
    NSMutableString *command = [NSMutableString stringWithFormat:@"UPDATE %@ SET %@ WHERE 1 = 1", tableName, [newValueString substringFromIndex:2]];
    
    for(NSString *key in parameters){
        [command appendFormat:@" AND %@ = ?", key];
        [commandHelper.parameters addObject:[NSString stringWithFormat:@"%@", [parameters objectForKey:key]]];
    }
    
    commandHelper.rawCommand = command;
    return commandHelper;
}

+(SqliteCommandHelper *) createCreateComand:(NSString *) tableName
                            andColumnValues:(NSDictionary *) columnValues{
    
    NSMutableString *columnList = [NSMutableString string];
    NSMutableString *valueMarkList = [NSMutableString string];
    NSMutableArray<NSString *> *valueList = [NSMutableArray<NSString *> new];
    
    for (NSString* key in columnValues) {
        id value = [columnValues objectForKey:key];
        
        [columnList appendFormat:@", %@", key];
        [valueMarkList appendString:@", ?"];
        
        //[valueList addObject:value];
        [valueList addObject:[NSString stringWithFormat:@"%@", value]];
    }
    
    SqliteCommandHelper *commandHelper = [SqliteCommandHelper new];
    commandHelper.rawCommand = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",
                                tableName,
                                [columnList substringFromIndex:2],
                                [valueMarkList substringFromIndex:2]];
    
    commandHelper.parameters = valueList;
    return commandHelper;
}


+(SqliteCommandHelper *) createDeleteComand:(SqliteBaseData *) data{
    return [self createDeleteComand:[[data class] tableName] andParameters:@{[data primaryColumnName] : [data primaryColumnValue]}];
}

+(SqliteCommandHelper *) createSaveComand:(SqliteBaseData *) data{
    if([data isNew]){
        //insert command
        return [self createCreateComand:[[data class] tableName]
                        andColumnValues:[data columnValuesExceptPrimary]];
    }else{
        //update command
        return [self createUpdateComand:[[data class] tableName]
                        andColumnValues:[data columnValuesExceptPrimary]
                          andParameters:@{[data primaryColumnName] : [data primaryColumnValue]}];
    }
}

@end
