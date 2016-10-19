//
//  YNKEntityBase.h
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

#define YNKEntityBase_AUTOID @"autoID"

@interface YNKEntityBase : NSObject

@property (nonatomic,assign) long long int autoID;

- (NSDictionary *)insertDict;

- (NSDictionary *)updateDictWithCondition:(NSString *)condition fields:(NSArray *)fields;

- (void)save;

- (void)populateWithResultSet:(FMResultSet *)resultSet;



@end

static const NSString *kYNKEntityBaseSqlKey = @"YYClassInfoSQLMakerSqlKey";
static const NSString *kYNKEntityBaseValueKey = @"YYClassInfoSQLMakerValueKey";

