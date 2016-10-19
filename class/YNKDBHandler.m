//
//  YNKDBHandler.m
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import "YNKDBHandler.h"
#import "YYClassInfo+YNKAdd.h"
#import "FMDB.h"
#import "YNKClassLoader.h"
#import "YNKEntityBase.h"

static NSString *_dbFileName = @"Database.db";

@implementation YNKDBHandler

+ (void)load {
    NSArray *classInfoArr = [YNKClassLoader loadClassInfosThatDeriveFromClass:[YNKEntityBase class]];
    [YNKDBHandler createDatabaseWithEntites:classInfoArr];
}

+ (void)dropAllTables {
    NSArray *classes = [YNKClassLoader loadClassThatDeriveFromClass:[YNKEntityBase class]];
    [YNKDBHandler dropTables:classes];
}

+ (FMDatabaseQueue *)sharedQueue {
    static FMDatabaseQueue *_sharedQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:_dbFileName];
        NSLog(@"__ path: %@",databasePath);
        _sharedQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    });
    
    return _sharedQueue;
}

+(void)throwException:(NSString*)message {
    NSException* ex = [NSException
                       exceptionWithName:@"DataAccessException"
                       reason:message
                       userInfo:nil];
    
    @throw ex;
}

+ (void)createDatabaseWithEntites:(NSArray<YYClassInfo *> *)classInfoArr {
    NSMutableString *sqls = [NSMutableString string];
    for (YYClassInfo *classInfo in classInfoArr) {
        [sqls appendString:[classInfo ynk_tableCreateSql]];
    }
    [[self sharedQueue] inDatabase:^(FMDatabase *db) {
        if (![db executeStatements:sqls]) {
            [self throwException:[NSString stringWithFormat:@"%s : \nsql : %@",__func__,[db lastErrorMessage]]];
        }
    }];
}

+ (void)dropTables:(NSArray<Class> *)classArr {
    NSMutableString *sqls = [NSMutableString string];
    for (Class class in classArr) {
        [sqls appendString:[NSString stringWithFormat:@"DROP TABLE %@;",[class description]]];
    }
    [[self sharedQueue] inDatabase:^(FMDatabase *db) {
        if (![db executeStatements:sqls]) {
            [self throwException:[NSString stringWithFormat:@"%s : \nsql : %@",__func__,[db lastErrorMessage]]];
        }
    }];
}

+ (void)saveEntity:(YNKEntityBase *)entity {
    NSDictionary *sqlValueDict = [entity insertDict];
    NSString *sql = [sqlValueDict objectForKey:kYNKEntityBaseSqlKey];
    NSArray *values = [sqlValueDict objectForKey:kYNKEntityBaseValueKey];
    return [self executeUpdate:sql args:values];
}

+ (void)saveEntitysInTransation:(NSArray<YNKEntityBase *> *)entitys {
    [[self sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (YNKEntityBase *entity in entitys) {
            NSDictionary *insertDict = [entity insertDict];
            NSString *sql = [insertDict objectForKey:kYNKEntityBaseSqlKey];
            NSArray *values = [insertDict objectForKey:kYNKEntityBaseValueKey];
            [db executeUpdate:sql withArgumentsInArray:values];
        }
    }];
}


+ (void)executeUpdate:(NSString *)sql {
    [self executeUpdate:sql args:nil];
}

+ (void)executeUpdate:(NSString *)sql args:(NSArray *)args {
    [[self sharedQueue] inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withArgumentsInArray:args]) {
            [self throwException:[NSString stringWithFormat:@"%s : \nsql : %@",__func__,[db lastErrorMessage]]];
        }
    }];
}

+ (NSArray<YNKEntityBase *> *)select:(Class)cls withSql:(NSString *)sql {
    return [self select:cls withSql:sql args:nil];
}

+ (NSArray<YNKEntityBase *> *)select:(Class)class withSql:(NSString *)sql args:(NSArray *)args {
    if (![class isSubclassOfClass:[YNKEntityBase class]]) {
        return nil;
    }
    NSMutableArray *entitys = [[NSMutableArray alloc] init];
    [[self sharedQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql withArgumentsInArray:args];
        while ([resultSet next]) {
            YNKEntityBase *entity = [[class alloc] init];
            [entity populateWithResultSet:resultSet];
            [entitys addObject:entity];
        }
    }];
    return entitys;
}

+ (YNKEntityBase *)selectOne:(Class)cls withSql:(NSString *)sql {
    return [self selectOne:cls withSql:sql args:nil];
}

+ (YNKEntityBase *)selectOne:(Class)cls withSql:(NSString *)sql args:(NSArray *)args {
    if (![cls isSubclassOfClass:[YNKEntityBase class]]) {
        return nil;
    }
    __block YNKEntityBase *entity = nil;
    [[self sharedQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql withArgumentsInArray:args];
        if ([resultSet next]) {
            entity = [[cls alloc] init];
            [entity populateWithResultSet:resultSet];
        }
    }];
    return entity;
}


/**
 根据autoID 更新数据表
 
 @param entity 实体
 */
+ (void)updateEntity:(YNKEntityBase *)entity {
    if (entity.autoID == 0) {
        [entity save];
    } else {
        [self updateEntity:entity condition:[NSString stringWithFormat:@"WHERE autoID=%lld",entity.autoID]];
    }
}

/**
 根据condition 更新数据表
 
 @param entity    实体
 @param condition 条件
 */
+ (void)updateEntity:(YNKEntityBase *)entity condition:(NSString *)condition {
    [self updateEntity:entity condition:condition fields:nil];
}


/**
 根据condition 更新数据表的指定字段
 
 @param entity    实体
 @param condition 条件
 @param fields    指定更新的字段
 */
+ (void)updateEntity:(YNKEntityBase *)entity condition:(NSString *)condition fields:(NSArray *)fields {
    NSDictionary *sqlValueDict = [entity updateDictWithCondition:condition fields:fields];
    NSString *sql = [sqlValueDict objectForKey:kYNKEntityBaseSqlKey];
    NSArray *values = [sqlValueDict objectForKey:kYNKEntityBaseValueKey];
    return [self executeUpdate:sql args:values];
}







@end
