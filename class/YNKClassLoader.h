//
//  YNKClassLoader.h
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYClassInfo.h"

@interface YNKClassLoader : NSObject

+ (NSArray<Class> *)loadClassThatDeriveFromClass:(Class)class;

+ (NSArray<YYClassInfo *> *)loadClassInfosThatDeriveFromClass:(Class)class;

@end
