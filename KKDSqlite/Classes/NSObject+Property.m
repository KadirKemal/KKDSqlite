//
//  NSObject+Property.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>


NSMutableArray *propertyNamesOfClass(Class klass) {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(klass, &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    for (unsigned int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}



@implementation NSObject (Property)

- (NSMutableArray *)allPropertyNames {
    NSMutableArray *classes = [NSMutableArray array];
    Class currentClass = [self class];
    while (currentClass != nil && currentClass != [NSObject class]) {
        [classes addObject:currentClass];
        currentClass = class_getSuperclass(currentClass);
    }
    
    NSMutableArray *names = [NSMutableArray array];
    [classes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(Class currentClass, NSUInteger idx, BOOL *stop) {
        [names addObjectsFromArray:propertyNamesOfClass(currentClass)];
    }];
    
    return names;
}

@end
