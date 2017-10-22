# KKDSqlite

[![CI Status](http://img.shields.io/travis/kadirkemal/KKDSqlite.svg?style=flat)](https://travis-ci.org/kadirkemal/KKDSqlite)
[![Version](https://img.shields.io/cocoapods/v/KKDSqlite.svg?style=flat)](http://cocoapods.org/pods/KKDSqlite)
[![License](https://img.shields.io/cocoapods/l/KKDSqlite.svg?style=flat)](http://cocoapods.org/pods/KKDSqlite)
[![Platform](https://img.shields.io/cocoapods/p/KKDSqlite.svg?style=flat)](http://cocoapods.org/pods/KKDSqlite)

KKDSqlite helps you to manage your sqlite database on ios applications.

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

//this method is important while saving county and it's cities in one transaction.
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

### Create
### Update
### Delete


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
In demo project, you will see how to create, delete, update data and also how to save or delete more than one data in one transaction.

In the demo project, countries are listed and when you select one of the countries, the cities of selected country will be listed.



There is a sqlite database in the sample project (demoDB.sqlite). In this database, there are two tables.




## Requirements


## Author

Kadir Kemal Dursun (https://github.com/KadirKemal)

## License

KKDSqlite is available under the MIT license. See the LICENSE file for more info.
