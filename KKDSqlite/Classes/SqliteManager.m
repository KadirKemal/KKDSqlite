//
//  SqliteManager.m
//  KKDSqlite
//
//  Created by Kadir Kemal Dursun on 26/07/2017.
//  Copyright © 2017 Kadir Kemal Dursun. All rights reserved.
//

#import "SqliteManager.h"
#import <sqlite3.h>


#import "SqliteCommandHelper.h"
#import "SqliteCommandCreator.h"

NSString *const KKDSqliteErrorDomain = @"com.kkd.sqlite";

@interface SqliteManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSString *databasePath;

-(void)copyDatabaseIntoDocumentsDirectory;

@end


@implementation SqliteManager

static id sharedSqliteManagerInstance = nil;

+ (void)configure:(NSString *) dbFileName{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSqliteManagerInstance = [[self alloc] initWithDatabaseFileName:dbFileName];
    });

}

+ (instancetype)sharedInstance{
    if(sharedSqliteManagerInstance == nil){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"You should call 'configure' method before using the SqliteManager" userInfo:nil];
    }
    
    return sharedSqliteManagerInstance;
}



#pragma mark - copy datebase to directory if needed

-(instancetype)initWithDatabaseFileName:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
                
        // Keep the database filename.
        self.databaseFilename = dbFilename;
        self.databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
        
        // Copy the database file into the documents directory if necessary.
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

-(void)copyDatabaseIntoDocumentsDirectory{
    // Check if the database file exists in the documents directory.
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.databasePath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:self.databasePath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

#pragma mark - Public Methods

-(Boolean) saveSqliteBaseData:(SqliteBaseData *) data error:(NSError **)error{
    sqlite3 *sqlite3Database;
    
    // Open the database.
    BOOL openDatabaseResult = [self openDatabase:&sqlite3Database];
    if(openDatabaseResult == SQLITE_OK) {
        Boolean isNew = data.isNew;
        
        NSNumber *lastInsertedId = [self executeQuery:sqlite3Database sqliteCommandHelper:[SqliteCommandCreator createSaveComand:data] error:error];
        if(error){
            return NO;
        }
        
        if(isNew){
            [data setPrimaryColumnValue:lastInsertedId];
        }
    }else{
        *error = [NSError errorWithDomain:KKDSqliteErrorDomain code:1000 userInfo:nil];
        return NO;
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
    return YES;
}

-(Boolean) saveSqliteBaseData:(SqliteBaseData *)data withChildren:(NSArray<SqliteBaseData *> *) children error:(NSError **)error{
    sqlite3 *sqlite3Database;
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([self.databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        sqlite3_exec(sqlite3Database, "BEGIN", 0, 0, 0); //BEGIN TRANSACTION
        
        Boolean isNew = data.isNew;
        
        NSNumber *lastInsertedId = [self executeQuery:sqlite3Database sqliteCommandHelper:[SqliteCommandCreator createSaveComand:data] error:error];
        if(error){
            sqlite3_exec(sqlite3Database, "ROLLBACK", 0, 0, 0);
            sqlite3_close(sqlite3Database);
            return NO;
        }
        
        if(isNew){
            [data setPrimaryColumnValue:lastInsertedId];
        }
        
        for (SqliteBaseData *child in children){
            [child bindToParent:data];
            
            isNew = child.isNew;
            
            NSError* error = nil;
            NSNumber *lastInsertedId = [self executeQuery:sqlite3Database sqliteCommandHelper:[SqliteCommandCreator createSaveComand:child] error:&error];
            if(error){
                sqlite3_exec(sqlite3Database, "ROLLBACK", 0, 0, 0);
                sqlite3_close(sqlite3Database);
                return NO;
            }
            
            if(isNew){
                [child setPrimaryColumnValue:lastInsertedId];
            }
        }
        
        //COMMIT TRANSACTION
        if (sqlite3_exec(sqlite3Database, "COMMIT", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(sqlite3Database));
        
    }else{
        *error = [NSError errorWithDomain:KKDSqliteErrorDomain code:1000 userInfo:nil];
        return NO;
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
    return YES;
}

-(Boolean) saveAllSqliteBaseData:(NSArray<SqliteBaseData *> *) dataList error:(NSError **)error{
    sqlite3 *sqlite3Database;
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([self.databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        sqlite3_exec(sqlite3Database, "BEGIN", 0, 0, 0); //BEGIN TRANSACTION
        
        for (SqliteBaseData *data in dataList){
            Boolean isNew = data.isNew;
            
            NSNumber *lastInsertedId = [self executeQuery:sqlite3Database sqliteCommandHelper:[SqliteCommandCreator createSaveComand:data] error:error];
            if(error){
                sqlite3_exec(sqlite3Database, "ROLLBACK", 0, 0, 0);
                sqlite3_close(sqlite3Database);
                return false;
            }
            
            if(isNew){
                [data setPrimaryColumnValue:lastInsertedId];
            }
        }
        
        //COMMIT TRANSACTION
        if (sqlite3_exec(sqlite3Database, "COMMIT", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(sqlite3Database));
        
    }else{
        return false;
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
    return true;
}

-(Boolean) deleteSqliteBaseData:(SqliteBaseData *) data error:(NSError **)error{
    sqlite3 *sqlite3Database;
    
    // Open the database.
    BOOL openDatabaseResult = [self openDatabase:&sqlite3Database];
    if(openDatabaseResult == SQLITE_OK) {
        [self executeQuery:sqlite3Database sqliteCommandHelper:[SqliteCommandCreator createDeleteComand:data] error:error];
        if(error){
            return NO;
        }
        [data resetPrimaryColumnValue];
    }else{
        *error = [NSError errorWithDomain:KKDSqliteErrorDomain code:1000 userInfo:nil];
        return NO;
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
    return YES;
}

-(Boolean) deleteAllSqliteBaseData:(NSArray<SqliteBaseData *> *) dataList error:(NSError **)error{
    sqlite3 *sqlite3Database;
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([self.databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        sqlite3_exec(sqlite3Database, "BEGIN", 0, 0, 0); //BEGIN TRANSACTION
        
        for (SqliteBaseData *data in dataList){
            
            [self executeQuery:sqlite3Database sqliteCommandHelper:[SqliteCommandCreator createDeleteComand:data] error:error];
            if(error){
                sqlite3_exec(sqlite3Database, "ROLLBACK", 0, 0, 0);
                sqlite3_close(sqlite3Database);
                return false;
            }
            [data resetPrimaryColumnValue];
            
        }
        
        //COMMIT TRANSACTION
        if (sqlite3_exec(sqlite3Database, "COMMIT", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(sqlite3Database));
        
    }else{
        return false;
    }
    
    // Close the database.
    [self closeDatabase:sqlite3Database];
    return true;
}

-(SqliteSelectResult *)loadDataFromDB:(NSString *)query error:(NSError **)error{
    SqliteCommandHelper *commandHelper = [SqliteCommandHelper new];
    commandHelper.rawCommand = query;
    
    return [self runExecutableQuery:commandHelper error:error];
}

-(SqliteSelectResult *) loadDataFromDB:(NSString *)tableName parameters:(NSDictionary *)parameters error:(NSError **)error{
    return [self loadDataFromDB:tableName parameters:parameters orderBy:nil error:error];
}

-(SqliteSelectResult *) loadDataFromDB:(NSString *)tableName parameters:(NSDictionary *)parameters orderBy:(NSString*)orderBy error:(NSError **)error{
    
    SqliteCommandHelper *commandHelper = [SqliteCommandCreator createSelectComand:tableName andParameters:parameters andOrderBy:orderBy];
    return [self runExecutableQuery:commandHelper error:error];
}

-(Boolean)executeSimpleQuery:(NSString *)command error:(NSError **)error{
    SqliteCommandHelper *commandHelper = [SqliteCommandHelper new];
    commandHelper.rawCommand = command;
    
    [self runExecutableQuery:commandHelper error:error];
    return YES;
}


#pragma mark - DB Operations

-(SqliteSelectResult *)runExecutableQuery:(SqliteCommandHelper *)sqliteCommandHelper error:(NSError **)error{
    SqliteSelectResult *result = [[SqliteSelectResult alloc] init];
    
    sqlite3 *sqlite3Database;
    
    // Open the database.
    BOOL openDatabaseResult = [self openDatabase:&sqlite3Database];
    if(openDatabaseResult == SQLITE_OK) {
    
        sqlite3_stmt *compiledStatement;
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, [sqliteCommandHelper.rawCommand UTF8String], -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            if(sqliteCommandHelper.parameters != nil){
                for(int i = 0;i <sqliteCommandHelper.parameters.count; i++){
                    sqlite3_bind_text(compiledStatement, i+1, [[sqliteCommandHelper.parameters objectAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
                }
            }
            
            // Loop through the results and add them to the results array row by row.
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Declare an array to keep the data for each fetched row.
                NSMutableArray *arrDataRow = [[NSMutableArray alloc] init];
                
                // Get the total number of columns.
                int totalColumns = sqlite3_column_count(compiledStatement);
                
                // Go through all columns and fetch each column data.
                for (int i=0; i<totalColumns; i++){
                    // Convert the column data to text (characters).
                    char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                    
                    // If there are contents in the currenct column (field) then add them to the current row array.
                    if (dbDataAsChars != NULL) {
                        // Convert the characters to string.
                        [arrDataRow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                    }else{
                        [arrDataRow addObject:@""];
                    }
                    
                    // Keep the current column name.
                    if (result.arrColumnNames.count != totalColumns) {
                        dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                        [result.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                    }
                }
                
                // Store each fetched data row in the results array, but first check if there is actually data.
                if (arrDataRow.count > 0) {
                    [result.arrResults addObject:arrDataRow];
                }
            }
        }
        else {
            // In the database cannot be opened then show the error message on the debugger.
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
            *error = [NSError errorWithDomain:KKDSqliteErrorDomain code:1000 userInfo:nil];
        }

        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
    }else{
        *error = [NSError errorWithDomain:KKDSqliteErrorDomain code:1000 userInfo:nil];
    }
    
    // Close the database.
    [self closeDatabase:sqlite3Database];
    return result;
}

-(Boolean) openDatabase:(sqlite3 **)sqlite3Database{
    return sqlite3_open([self.databasePath UTF8String], sqlite3Database);
}

-(void) closeDatabase:(sqlite3 *)sqlite3Database{
    sqlite3_close(sqlite3Database);;
}

-(NSNumber *) executeQuery:(sqlite3 *)sqlite3Database sqliteCommandHelper:(SqliteCommandHelper *)sqliteCommandHelper error:(NSError **)error{
    long lastInsertedRowID = 0;
    
    // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
    sqlite3_stmt *compiledStatement;
    
    // Load all data from database to memory.
    BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, [sqliteCommandHelper.rawCommand UTF8String], -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        // This is the case of an executable query (insert, update, ...).
        
        if(sqliteCommandHelper.parameters != nil){
            for(int i = 0;i <sqliteCommandHelper.parameters.count; i++){
                sqlite3_bind_text(compiledStatement, i+1, [[sqliteCommandHelper.parameters objectAtIndex:i] UTF8String], -1, SQLITE_TRANSIENT);
            }
        }
        
        // Execute the query.
        int executeQueryResults = sqlite3_step(compiledStatement);
        if (executeQueryResults == SQLITE_DONE) {
            lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
        }else{
            // If could not execute the query show the error message on the debugger.
            NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
            *error = [NSError errorWithDomain:KKDSqliteErrorDomain code:1000 userInfo:nil];
        }
    }
    else {
        // In the database cannot be opened then show the error message on the debugger.
        NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        *error = [NSError errorWithDomain:KKDSqliteErrorDomain code:1000 userInfo:nil];
    }
    
    // Release the compiled statement from memory.
    sqlite3_finalize(compiledStatement);
    return @(lastInsertedRowID);
}

@end
