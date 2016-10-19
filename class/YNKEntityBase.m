//
//  YNKEntityBase.m
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import "YNKEntityBase.h"
#import "YYClassInfo+YNKAdd.h"
#import "YNKDBHandler.h"
#import "FMResultSet.h"

@implementation YNKEntityBase

- (void)save {
    [YNKDBHandler saveEntity:self];
}

- (NSDictionary *)insertDict {
    YYClassInfo *info = [YYClassInfo classInfoWithClass:[self class]];
    NSDictionary *sqlValue = [info ynk_tableInsertSql:self];
    return sqlValue;
}

- (NSDictionary *)updateDictWithCondition:(NSString *)condition fields:(NSArray *)fields {
    YYClassInfo *info = [YYClassInfo classInfoWithClass:[self class]];
    NSDictionary *sqlValue = [info ynk_tableUpdateSql:self condition:condition fields:fields];
    return sqlValue;
}

- (void)populateWithResultSet:(FMResultSet *)resultSet {
    YYClassInfo *info = [YYClassInfo classInfoWithClass:[self class]];
    for (YYClassPropertyInfo *property in info.propertyInfos.allValues) {
        if ([property ynk_persistentEnable]) {
            id value = [resultSet objectForColumnName:property.name];
            [self setValue:value forKey:property.name];
        }
    }
}

@end
