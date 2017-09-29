//
//  SqliteManager.h
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SqliteSelectResult.h"
#import "SqliteBaseData.h"

@interface SqliteManager : NSObject

FOUNDATION_EXPORT NSString *const KKDSqliteErrorDomain;

+ (void)configure:(NSString *) dbFileName;
+ (instancetype)sharedInstance;

-(Boolean) saveSqliteBaseData:(SqliteBaseData *) data error:(NSError **)error;
-(Boolean) saveSqliteBaseData:(SqliteBaseData *)data withChildren:(NSArray<SqliteBaseData *> *) children error:(NSError **)error;
-(Boolean) saveAllSqliteBaseData:(NSArray<SqliteBaseData *> *) dataList error:(NSError **)error;

-(Boolean) deleteSqliteBaseData:(SqliteBaseData *) data error:(NSError **)error;
-(Boolean) deleteAllSqliteBaseData:(NSArray<SqliteBaseData *> *) dataList error:(NSError **)error;


-(SqliteSelectResult *) loadDataFromDB:(NSString *)query error:(NSError **)error;
-(SqliteSelectResult *) loadDataFromDB:(NSString *)tableName parameters:(NSDictionary *)parameters error:(NSError **)error;
-(SqliteSelectResult *) loadDataFromDB:(NSString *)tableName parameters:(NSDictionary *)parameters orderBy:(NSString*)orderBy error:(NSError **)error;


-(Boolean)executeSimpleQuery:(NSString *)command error:(NSError **)error;

@end
