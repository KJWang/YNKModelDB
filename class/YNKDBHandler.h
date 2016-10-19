//
//  YNKDBHandler.h
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYClassInfo.h"
#import "YNKEntityBase.h"

@interface YNKDBHandler : NSObject


/**
 清空所有的数据表
 */
+ (void)dropAllTables;


/**
 保存实体

 @param entity YNKEntityBase实体
 */
+ (void)saveEntity:(YNKEntityBase *)entity;


/**
 在事务中保存多个实体，保证线程同步

 @param entitys 实体对象的数组
 */
+ (void)saveEntitysInTransation:(NSArray<YNKEntityBase *> *)entitys;


/**
 执行更新操作 DELETE UPDATE等insert之外的sql语句

 @param sql sql文
 */
+ (void)executeUpdate:(NSString *)sql;


/**
 使用占位符更新数据表 防止sql中有非法字符

 @param sql  sql文
 @param args 参数
 */
+ (void)executeUpdate:(NSString *)sql args:(NSArray *)args;


/**
 查询数据库中某个类的实体数组

 @param cls 指定那个表
 @param sql sql

 @return YNKEntityBase数组
 */
+ (NSArray<YNKEntityBase *> *)select:(Class)cls withSql:(NSString *)sql;

/**
 使用占位符 查询数据库中某个类的实体数组
 
 @param cls     指定那个表
 @param sql     sql
 @param args    参数
 @return YNKEntityBase数组
 */
+ (NSArray<YNKEntityBase *> *)select:(Class)cls withSql:(NSString *)sql args:(NSArray *)args;


/**
 查询数据库中某个类的一个实体对象
 
 @param cls 指定那个表
 @param sql sql
 
 @return YNKEntityBase实体
 */
+ (YNKEntityBase *)selectOne:(Class)cls withSql:(NSString *)sql;

/**
 使用占位符 查询数据库中某个类的一个实体对象
 
 @param cls     指定那个表
 @param sql     sql
 @param args    参数
 @return YNKEntityBase实体
 */
+ (YNKEntityBase *)selectOne:(Class)cls withSql:(NSString *)sql args:(NSArray *)args;


/**
 根据autoID 更新数据表

 @param entity 实体
 */
+ (void)updateEntity:(YNKEntityBase *)entity;

/**
 根据condition 更新数据表

 @param entity    实体
 @param condition 条件
 */
+ (void)updateEntity:(YNKEntityBase *)entity condition:(NSString *)condition;


/**
 根据condition 更新数据表的指定字段

 @param entity    实体
 @param condition 条件
 @param fields    指定更新的字段
 */
+ (void)updateEntity:(YNKEntityBase *)entity condition:(NSString *)condition fields:(NSArray *)fields;

@end
