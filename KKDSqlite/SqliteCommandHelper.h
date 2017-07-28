//
//  SqliteCommandHelper.h
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteCommandHelper : NSObject

@property NSString* rawCommand;
@property NSMutableArray<NSString *> *parameters;

@end
