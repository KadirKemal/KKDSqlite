//
//  SqliteBaseData.h
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBIgnore
@end

/*
@protocol DBNullableColumn
@end

@protocol DBKeyColumn
@end
*/
 
@interface SqliteBaseData : NSObject

+(NSString *) tableName;

+(NSMutableArray <SqliteBaseData*>*) modelListFromDB:(NSDictionary *) params;
+(NSMutableArray <SqliteBaseData*>*) modelListFromDB:(NSDictionary *) params orderBy:(NSString*) orderBy;
+(NSMutableArray <SqliteBaseData*>*) modelListWithCommand:(NSString *) command;




@property int id;
@property (nonatomic)id primaryColumnValue;

-(instancetype) initWithId:(int) id;

-(NSString *) primaryColumnName;
-(NSNumber *) primaryColumnValue;
-(void)resetPrimaryColumnValue;
-(BOOL)isNew;

-(NSMutableDictionary *) columnValues;
-(NSMutableDictionary *) columnValuesExceptPrimary;

-(void) bindToParent:(SqliteBaseData *) parent;

-(BOOL)saveMe;
-(BOOL)deleteMe;

-(BOOL)saveMeWith:(NSArray <SqliteBaseData*>*) dataList;
-(BOOL)saveMeWithChildren:(NSArray <SqliteBaseData*>*) dataList;

-(BOOL)deleteMeWith:(NSArray <SqliteBaseData*>*) dataList;


/*
-(NSMutableDictionary *) allDBPropertiesAndValues;

*/
@end
