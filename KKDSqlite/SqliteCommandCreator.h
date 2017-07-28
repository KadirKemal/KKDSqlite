//
//  SqliteCommandCreator.h
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SqliteCommandHelper.h"
#import "SqliteBaseData.h"

@interface SqliteCommandCreator : NSObject

+(SqliteCommandHelper *) createSelectComand:(NSString *) tableName
                              andParameters:(NSDictionary *) parameters;

+(SqliteCommandHelper *) createSelectComand:(NSString *) tableName
                              andParameters:(NSDictionary *) parameters
                                 andOrderBy:(NSString*) orderBy;

+(SqliteCommandHelper *) createDeleteComand:(NSString *) tableName
                              andParameters:(NSDictionary *) parameters;

+(SqliteCommandHelper *) createUpdateComand:(NSString *) tableName
                            andColumnValues:(NSDictionary *) columnValues
                              andParameters:(NSDictionary *) parameters;

+(SqliteCommandHelper *) createCreateComand:(NSString *) tableName
                            andColumnValues:(NSDictionary *) columnValues;


+(SqliteCommandHelper *) createDeleteComand:(SqliteBaseData *) data;
+(SqliteCommandHelper *) createSaveComand:(SqliteBaseData *) data;



@end
