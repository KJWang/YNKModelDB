//
//  YNKClassLoader.m
//  yunke_plus
//
//  Created by Wang on 2016/10/18.
//  Copyright © 2016年 云客. All rights reserved.
//

#import "YNKClassLoader.h"
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <objc/runtime.h>

@implementation YNKClassLoader

+ (NSArray<Class> *)loadClassThatDeriveFromClass:(Class)class {
    return [self loadClassWithCondition:^BOOL(__unsafe_unretained Class _class) {
        return ([_class isSubclassOfClass:class] && ![[_class description] isEqualToString:[class description]]);
    }];
}

+ (NSArray<Class> *)loadClassWithCondition:(BOOL (^)(Class))condition {
    NSMutableArray *clsArr = [NSMutableArray array];
    
    unsigned int count;
    const char **classes;
    
    Dl_info info;
    dladdr(&MH_EXECUTE_SYM, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname,&count);
    for (int i = 0; i < count; i ++) {
        Class class = NSClassFromString([NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding]);
        if (condition && condition(class)) {
            [clsArr addObject:class];
        }
    }
    return clsArr;
}

+ (NSArray<YYClassInfo *> *)loadClassInfosThatDeriveFromClass:(Class)class {
    return [self loadClassInfoWithCondition:^BOOL(__unsafe_unretained Class _class) {
        return ([_class isSubclassOfClass:class] && ![[_class description] isEqualToString:[class description]]);
    }];
}

+ (NSArray<YYClassInfo *> *)loadClassInfoWithCondition:(BOOL (^)(Class))condition {
    NSMutableArray *clsInfoArr = [NSMutableArray array];
    
    unsigned int count;
    const char **classes;
    
    Dl_info info;
    dladdr(&MH_EXECUTE_SYM, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname,&count);
    for (int i = 0; i < count; i ++) {
        Class class = NSClassFromString([NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding]);
        if (condition && condition(class)) {
            YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:class];
            [clsInfoArr addObject:classInfo];
        }
    }
    return clsInfoArr;
}




@end
