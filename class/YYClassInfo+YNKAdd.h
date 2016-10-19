//
//  YYClassInfo+YNKAdd.h
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import "YYClassInfo.h"
#import "YNKEntityBase.h"

#define YNK_SQLITETYPE_TEXT @"TEXT"
#define YNK_SQLITETYPE_REAL @"REAL"
#define YNK_SQLITETYPE_INTEGER @"INTEGER"

@interface YYClassPropertyInfo (YNKAdd)

- (NSString *)ynk_sqlliteType;

- (BOOL)ynk_persistentEnable;

@end

@interface YYClassInfo (YNKAdd)

- (NSString *)ynk_tableCreateSql;

- (NSString *)ynk_tableDropSql;

- (NSDictionary *)ynk_tableInsertSql:(YNKEntityBase *)entity;


/**
 更新语句

 @param entity    更新的实体对象
 @param condition 条件字符串 @"WHERE key = value"
 @param fields    指定更新的字段

 @return sql & values
 */
- (NSDictionary *)ynk_tableUpdateSql:(YNKEntityBase *)entity condition:(NSString *)condition fields:(NSArray*) fields;

@end

