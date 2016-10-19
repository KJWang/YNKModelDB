//
//  YNKEntityBasePrimaryKey.h
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import <Foundation/Foundation.h>

DEPRECATED_ATTRIBUTE
@protocol YNKEntityBasePrimaryKey <NSObject>

@required
- (NSString *)primaryKey;

@end
