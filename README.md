# KKDSqlite

[![CI Status](http://img.shields.io/travis/kadirkemal/KKDSqlite.svg?style=flat)](https://travis-ci.org/kadirkemal/KKDSqlite)
[![Version](https://img.shields.io/cocoapods/v/KKDSqlite.svg?style=flat)](http://cocoapods.org/pods/KKDSqlite)
[![License](https://img.shields.io/cocoapods/l/KKDSqlite.svg?style=flat)](http://cocoapods.org/pods/KKDSqlite)
[![Platform](https://img.shields.io/cocoapods/p/KKDSqlite.svg?style=flat)](http://cocoapods.org/pods/KKDSqlite)

KKDSqlite helps you to manage sqlite database on ios applications.

## Installation

KKDSqlite is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KKDSqlite'
```

## How To Use
### Step 1
Create database for your project. This library uses pre-created sqlitedatabase. You can create sqlite database by using SQLiteStudio or similar programs.

In demo project, you will see sqlitedatabse (demoDB.sqlite), and there are two tables in that database.
```sql
CREATE TABLE Countries (
    id   PRIMARY KEY,
    name VARCHAR (50)
);

CREATE TABLE Cities (
    id   PRIMARY KEY,
    countryId INTEGER,
    name VARCHAR (50)
);
```

### Step 2
Create the models. While creating you models, the column names in the table and propery names in the class should be same.

```objc
--- .h file
#import "SqliteBaseData.h"
@interface Country : SqliteBaseData

@property (nonatomic) NSString* name;

@end

--- .m file
#import "Country.h"

@implementation Country

//this method should be overriden
+(NSString *)tableName{
    return @"Countries";
}

@end
```

```objc
--- .h file
#import "SqliteBaseData.h"

@interface City : SqliteBaseData

@property (nonatomic) NSString* name;
@property (nonatomic) int countryId;

@end


--- .m file
#import "City.h"

@implementation City

+(NSString *)tableName{
    return @"Cities";
}

//this method is important while saving country and it's cities in one transaction.
//For foreign keys, you need to set value in this method.
-(void)bindToParent:(SqliteBaseData *)parent{
    _countryId = parent.id;
}

@end
```

### Step 3
Before executing any command, you should configure sqliteManager with database file name. It is suggested doing this in appDelegate.

```objc

#import "SqliteManager.h"


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //in the sample project, the name of the database file is demoDB.sqlite
    [SqliteManager configure:@"demoDB.sqlite"];

    return YES;
}

```

##  Operations
### Select
For getting data from sqlite database you can use these methods;
```objc
+(NSMutableArray <SqliteBaseData*>*) modelListFromDB:(NSDictionary *) params;

+(NSMutableArray <SqliteBaseData*>*) modelListFromDB:(NSDictionary *) params orderBy:(NSString*) orderBy;

+(NSMutableArray <SqliteBaseData*>*) modelListWithCommand:(NSString *) command;
```

#### Examples

If you want to select all countries from the sqlite database, you only need to do
```objc
NSMutableArray *countryList = [Country modelListFromDB:nil];
```

If you want to order the result
```objc
//do not forget to add "order by"
//you can add more columns, for example "order by firstName desc, lastName asc"
NSMutableArray *countryList = [Country modelListFromDB:nil orderBy:@"order by name"];
```

If you want to select cities by filtering countryId = 1, you only need to do
```objc
//you can add more parameters, keys values of dictionary should be one of the column names in cities table
NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"countryId", nil];
NSMutableArray *cityList = [City modelListFromDB:params];
```

If you want to execute your own command
```objc
//You should select cities.*, because instance list of cityModel will be created by result
NSMutableArray *cityList = [City modelListWithCommand:@"SELECT cities.* FROM cities INNER JOIN countries ..."];
```

### Select operations with callback
callback is executed in main thread.

```objc
+(void) modelListFromDB:(NSDictionary *) params success:(void(^)(NSMutableArray <SqliteBaseData*>*))callback;

+(void) modelListFromDB:(NSDictionary *) params orderBy:(NSString*) orderBy success:(void(^)(NSMutableArray <SqliteBaseData*>*))callback;

+(void) modelListWithCommand:(NSString *) command success:(void(^)(NSMutableArray <SqliteBaseData*>*))callback;
```

#### Examples
If you want to select all countries from the sqlite database with callback
```objc
[Country modelListFromDB:nil
                 success:^(NSMutableArray<SqliteBaseData *> *list) {
                     _countryList = list;
                     [_table reloadData];
                 }
];
```

If you want to order the result
```objc
[Country modelListFromDB:nil
                 orderBy:@"order by name"
                 success:^(NSMutableArray<SqliteBaseData *> *list) {
                     _countryList = list;
                     [_table reloadData];
                 }
];
```

If you want to select cities by filtering countryId = 1, you only need to do
```objc
NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"countryId", nil];
[City modelListFromDB:params
              success:^(NSMutableArray<SqliteBaseData *> *list) {
                  _cityList = list;
                  [_table reloadData];
              }
];
```

If you want to execute your own command
```objc
//You should select cities.*, because instance list of cityModel will be created by result
[City modelListWithCommand:@"SELECT cities.* FROM cities INNER JOIN countries ..."
                   success:^(NSMutableArray<SqliteBaseData *> *list) {
                       _cityList = list;
                       [_table reloadData];
                   }
];
```


### Create and Update
If you have a Model that is inherited from SqliteBaseData, you only need to call saveMe method to create or update.
If the id of the instance is 0, create method would be generated and executed.
If the id is not 0, update method would be generated and executed.

#### Examples

```objc
City *city = [City new];
city.name = @"Paris";
[city saveMe];
//as city id is 0, a new row would be added to cities table.
//After inserting, id of this instance will automatically set.
```

```objc
NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"id", nil];
NSMutableArray *cityList = [City modelListFromDB:params];

City *city = [cityList objectAtIndex:0];
city.name = @"Paris";
[city saveMe];
//as city id is not 0, the related row will be updated.
```

### Delete
If you have a Model that is inherited from SqliteBaseData, you only need to call deleteMe method to delete.

#### Examples
```objc
NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"id", nil];
NSMutableArray *cityList = [City modelListFromDB:params];

City *city = [cityList objectAtIndex:0];
[city deleteMe];
```


### Create, Update or Delete many instances in one transaction
According to your purpose, you can use one of these methods;
```objc
-(BOOL)saveMeWith:(NSArray <SqliteBaseData*>*) dataList;

-(BOOL)saveMeWithChildren:(NSArray <SqliteBaseData*>*) dataList;

-(BOOL)deleteMeWith:(NSArray <SqliteBaseData*>*) dataList;
```

If you use saveMeWithChildren method;
after saving (creating or updating) the parent instance, bindToParent method would be called for every instances in dataList.

#### Examples
```objc
//in City.m file
-(void)bindToParent:(SqliteBaseData *)parent{
    _countryId = parent.id;
}
```

```objc
Country *country = [[Country alloc] initWithName:@"A Name"];

NSMutableArray<SqliteBaseData *> *cityList = [NSMutableArray new];
[cityList addObject:[[City alloc] initWithName:@"city 1"];
[cityList addObject:[[City alloc] initWithName:@"city 2"];
[cityList addObject:[[City alloc] initWithName:@"city 3"];
[cityList addObject:[[City alloc] initWithName:@"city 4"];
[cityList addObject:[[City alloc] initWithName:@"city 5"];

[country saveMeWithChildren:cityList];
//after country is saved, id value of the country will be set.
//before saving cityList, bindToParent method will be called for every instances
//and for this example the countryId of city instances will be set
//If saveMeWith method is used, bindToParent method will not be called
```

#### Examples
```objc
NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"id", nil];
NSMutableArray *countryList = [Country modelListFromDB:params];

Country *country = [countryList objectAtIndex:1];

params = [NSDictionary dictionaryWithObjectsAndKeys:@(country.id), @"countryId", nil];
NSMutableArray *cityList = [City modelListFromDB:params];

//to delete all items in one transaction
[country deleteMeWith:cityList];
```

## Author

Kadir Kemal Dursun (https://github.com/KadirKemal)

## License

KKDSqlite is available under the MIT license. See the LICENSE file for more info.
