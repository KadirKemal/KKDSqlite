//
//  SqliteBaseData.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import "SqliteBaseData.h"
#import "Constants.h"

#import "NSObject+Property.h"
#import <objc/runtime.h>

#import "SqliteManager.h"


@implementation SqliteBaseData

+(NSString *) tableName{
    mustOverride();
}

+(NSMutableArray <SqliteBaseData*>*) modelListFromDB:(NSDictionary *) params{
    SqliteSelectResult *result = [[SqliteManager sharedInstance] loadDataFromDB:[self tableName] parameters:params error:nil];
    return [self convertSqliteSelectResultToModelArray:result];
}

+(NSMutableArray <SqliteBaseData*>*) modelListFromDB:(NSDictionary *) params orderBy:(NSString*) orderBy{
    SqliteSelectResult *result = [[SqliteManager sharedInstance] loadDataFromDB:[self tableName] parameters:params orderBy:orderBy error:nil];
    return [self convertSqliteSelectResultToModelArray:result];
}

+(NSMutableArray <SqliteBaseData*>*) modelListWithCommand:(NSString *) command{
    SqliteSelectResult *result = [[SqliteManager sharedInstance] loadDataFromDB:command error:nil];
    return [self convertSqliteSelectResultToModelArray:result];
}

+(NSMutableArray *) convertSqliteSelectResultToModelArray:(SqliteSelectResult *) result{
    NSMutableArray *objList = [[NSMutableArray alloc] init];
    
    if([result.arrResults count] == 0){
        return objList;
    }
    
    id ins = [self new];
    NSMutableArray *allPropertyNames = [ins allPropertyNames];
    
    for(NSArray *arr in result.arrResults){
        ins = [self new];
        for(NSString *propertyName in allPropertyNames){
            if([result.arrColumnNames containsObject:propertyName]){
                NSInteger index = [result.arrColumnNames indexOfObject:propertyName];
                
                if([propertyName isEqualToString:@"enable"]){ //for iPhone 5
                    int intValue = [[arr objectAtIndex:index] intValue];
                    Boolean b = (intValue!=0);
                    [ins setValue:@(b) forKey:propertyName];
                }else{
                    [ins setValue:[arr objectAtIndex:index] forKey:propertyName];
                }
            }
        }
        [objList addObject:ins];
    }
    
    return objList;
}



-(instancetype) initWithId:(int) id{
    self = [super init];
    if(self){
        //todo
    }
    return self;
}

-(NSString *) primaryColumnName{
    return @"id";
}

-(NSNumber *) primaryColumnValue{
    return @(self.id);
}

-(void)setPrimaryColumnValue:(NSNumber *)primaryColumnValue{
    self.id = [primaryColumnValue intValue];
}

-(void)resetPrimaryColumnValue{
    self.id = 0;
}

-(BOOL)isNew{
    return _id == 0;
}

-(NSMutableDictionary *) columnValues{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSMutableArray *allPropertyNames = [self allPropertyNames];
    for(NSString *propertyName in allPropertyNames){
        const char * type = property_getAttributes(class_getProperty([self class], [propertyName UTF8String]));
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        //const char * rawPropertyType = [propertyType UTF8String];
        
        if ([propertyType rangeOfString:@"<DBIgnore>"].location != NSNotFound
            || [propertyType rangeOfString:@"NSMutableArray"].location != NSNotFound
            || [propertyType rangeOfString:@"NSArray"].location != NSNotFound
            || [propertyType rangeOfString:@"NSMutableDictionary"].location != NSNotFound
            || [propertyType rangeOfString:@"NSDictionary"].location != NSNotFound) {
            
            continue;
            
        }
        
        [dict setValue:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    return dict;
}

-(NSMutableDictionary *) columnValuesExceptPrimary{
    NSMutableDictionary *dict = [self columnValues];
    [dict removeObjectForKey:self.primaryColumnName];
    return dict;
}

-(void) bindToParent:(SqliteBaseData *) parent{
    
}

-(BOOL)saveMe{
    return [[SqliteManager sharedInstance] saveSqliteBaseData:self error:nil];
}

-(BOOL)deleteMe{
    return [[SqliteManager sharedInstance] deleteSqliteBaseData:self error:nil];
}

-(BOOL)saveMeWith:(NSArray <SqliteBaseData*>*) dataList{
    NSMutableArray<SqliteBaseData*>* arr = [NSMutableArray arrayWithArray:dataList];
    [arr addObject:self];
    
    return [[SqliteManager sharedInstance] saveAllSqliteBaseData:arr error:nil];
}

-(BOOL)saveMeWithChildren:(NSArray <SqliteBaseData*>*) dataList{
    return [[SqliteManager sharedInstance] saveSqliteBaseData:self withChildren:dataList error:nil];
}

-(BOOL)deleteMeWith:(NSArray <SqliteBaseData*>*) dataList{
    NSMutableArray<SqliteBaseData*>* arr = [NSMutableArray arrayWithArray:dataList];
    [arr addObject:self];
    
    return [[SqliteManager sharedInstance] deleteAllSqliteBaseData:arr error:nil];
}



@end
