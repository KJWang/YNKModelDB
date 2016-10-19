//
//  YYClassInfo+YNKAdd.m
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import "YYClassInfo+YNKAdd.h"
#import "YNKEntityBasePrimaryKey.h"

@implementation YYClassPropertyInfo (YNKAdd)


- (NSString *)ynk_sqlliteType {
    if ((self.type & YYEncodingTypePropertyMask) & YYEncodingTypePropertyReadonly) {
        return nil;
    }
    switch (self.type & YYEncodingTypeMask) {
        case YYEncodingTypeBool:
        case YYEncodingTypeInt8:
        case YYEncodingTypeUInt8:
        case YYEncodingTypeInt16:
        case YYEncodingTypeUInt16:
        case YYEncodingTypeInt32:
        case YYEncodingTypeUInt32:
        case YYEncodingTypeInt64:
        case YYEncodingTypeUInt64: {
            return YNK_SQLITETYPE_INTEGER;
        } break;
        case YYEncodingTypeFloat      :
        case YYEncodingTypeDouble     :
        case YYEncodingTypeLongDouble : {
            return YNK_SQLITETYPE_REAL;
        } break;
            
        case YYEncodingTypeObject: {
            if ([self.cls isSubclassOfClass:[NSString class]]) {
                return YNK_SQLITETYPE_TEXT;
            } else {
                return nil;
            }
        } break;
        
        default:
            return nil;
            break;
    }
}

- (BOOL)ynk_persistentEnable {
    if ((self.type & YYEncodingTypePropertyMask) & YYEncodingTypePropertyReadonly) {
        return NO;
    }
    switch (self.type & YYEncodingTypeMask) {
        case YYEncodingTypeBool:
        case YYEncodingTypeInt8:
        case YYEncodingTypeUInt8:
        case YYEncodingTypeInt16:
        case YYEncodingTypeUInt16:
        case YYEncodingTypeInt32:
        case YYEncodingTypeUInt32:
        case YYEncodingTypeInt64:
        case YYEncodingTypeUInt64:
        case YYEncodingTypeFloat:
        case YYEncodingTypeDouble:
        case YYEncodingTypeLongDouble : {
            return YES;
        } break;
        case YYEncodingTypeObject: {
            if ([self.cls isSubclassOfClass:[NSString class]]) {
                return YES;
            } else {
                return NO;
            }
        } break;
            
        default:
            return NO;
            break;
    }
}

@end

@implementation YYClassInfo (YNKAdd)



- (NSString *)ynk_tableCreateSql {
    if (![self.cls isSubclassOfClass:[YNKEntityBase class]]) {
        return nil;
    }
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@",self.name];
    
    NSArray *allPropertys = [self allPropertys];

    NSMutableArray *propertySubSqlArr = [NSMutableArray array];
    
    for (YYClassPropertyInfo *property in allPropertys) {
        NSString *sqliteType = [property ynk_sqlliteType];
        if (sqliteType) {
            NSString *sql = [NSString stringWithFormat:@"%@ %@",property.name,sqliteType];
            if ([property.name isEqualToString:YNKEntityBase_AUTOID]) {
                sql = [sql stringByAppendingString:@" PRIMARY KEY AUTOINCREMENT"];
            }
            [propertySubSqlArr addObject:sql];
        }
    }
    if (propertySubSqlArr.count) {
        sql = [sql stringByAppendingFormat:@" (%@)",[propertySubSqlArr componentsJoinedByString:@","]];
    }
    
    sql = [sql stringByAppendingString:@";"];
    
    return sql;
}

- (NSArray *)allPropertys {
    NSMutableArray *mArr = [NSMutableArray array];
    [mArr addObjectsFromArray:self.propertyInfos.allValues];
    if (![self.superClassInfo.name isEqualToString:@"NSObject"]) {
        [mArr addObjectsFromArray:[self.superClassInfo allPropertys]];
    }
    return mArr;
}

- (NSString *)ynk_tableDropSql {
    return [NSString stringWithFormat:@"DROP TABLE %@;",self.name];
}

- (NSDictionary *)ynk_tableInsertSql:(YNKEntityBase *)entity {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@",self.name];
    NSMutableArray *propertyNameArr = [NSMutableArray array];
    NSMutableArray *propertyValueArr = [NSMutableArray array];
    NSMutableArray *propertyValuePlaceholderArr = [NSMutableArray array];

    NSArray *allPropertys = [self allPropertys];

    for (YYClassPropertyInfo *property in allPropertys) {
        if ([property.name isEqualToString:YNKEntityBase_AUTOID]) {
            continue;
        }
        NSString *sqliteType = [property ynk_sqlliteType];
        if ([sqliteType isEqualToString:YNK_SQLITETYPE_TEXT]) {
            NSString *value = [entity valueForKey:property.name];
            if (!value) {
                value = @"";
            }
            [propertyValuePlaceholderArr addObject:@"?"];
            [propertyNameArr addObject:property.name];
            [propertyValueArr addObject:value];
        } else if ([sqliteType isEqualToString:YNK_SQLITETYPE_INTEGER]) {
            int value = [[entity valueForKey:property.name] intValue];
            [propertyValuePlaceholderArr addObject:@"?"];
            [propertyNameArr addObject:property.name];
            [propertyValueArr addObject:@(value)];
        } else if ([sqliteType isEqualToString:YNK_SQLITETYPE_REAL]) {
            double value = [[entity valueForKey:property.name] doubleValue];
            [propertyValuePlaceholderArr addObject:@"?"];
            [propertyNameArr addObject:property.name];
            [propertyValueArr addObject:@(value)];
        }
    }
    if (propertyValueArr.count) {
        sql = [sql stringByAppendingFormat:@" (%@) VALUES (%@)",[propertyNameArr componentsJoinedByString:@","],[propertyValuePlaceholderArr componentsJoinedByString:@","]];
    }
    
    sql = [sql stringByAppendingString:@";"];
    
    return @{kYNKEntityBaseSqlKey:sql,kYNKEntityBaseValueKey:propertyValueArr};
}

- (NSDictionary *)ynk_tableUpdateSql:(YNKEntityBase *)entity condition:(NSString *)condition fields:(NSArray*) fields {
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@",self.name];
    NSMutableArray *propertySqlArr = [NSMutableArray array];
    NSMutableArray *propertyValueArr = [NSMutableArray array];
    
    NSArray *allPropertys = [self allPropertys];
    
    for (YYClassPropertyInfo *property in allPropertys) {
        if (fields && ![fields containsObject:property.name]) {
            continue;
        }
        if ([property.name isEqualToString:YNKEntityBase_AUTOID]) {
            continue;
        }
        NSString *sqliteType = [property ynk_sqlliteType];
        if ([sqliteType isEqualToString:YNK_SQLITETYPE_TEXT]) {
            NSString *value = [entity valueForKey:property.name];
            if (!value) {
                value = @"";
            }
            [propertySqlArr addObject:[NSString stringWithFormat:@"%@ = ?",property.name]];
            [propertyValueArr addObject:value];
        } else if ([sqliteType isEqualToString:YNK_SQLITETYPE_INTEGER]) {
            int value = [[entity valueForKey:property.name] intValue];
            [propertySqlArr addObject:[NSString stringWithFormat:@"%@ = ?",property.name]];
            [propertyValueArr addObject:@(value)];
        } else if ([sqliteType isEqualToString:YNK_SQLITETYPE_REAL]) {
            double value = [[entity valueForKey:property.name] doubleValue];
            [propertySqlArr addObject:[NSString stringWithFormat:@"%@ = ?",property.name]];
            [propertyValueArr addObject:@(value)];
        }
    }
    if (propertyValueArr.count) {
        sql = [sql stringByAppendingFormat:@" SET %@ ",[propertySqlArr componentsJoinedByString:@","]];
    }
    
    if (condition) {
        sql = [sql stringByAppendingString:condition];
    }
    
    sql = [sql stringByAppendingString:@";"];
    
    return @{kYNKEntityBaseSqlKey:sql,kYNKEntityBaseValueKey:propertyValueArr};
}


@end
