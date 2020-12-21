//
//  Tools.h
//  FundLook
//
//  Created by yjs on 2020/12/17.
//

#import <Foundation/Foundation.h>

#define TXSingletonH(name) + (instancetype)shared##name;
// .m文件
#define TXSingletonM(name) \
static id _instance; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject
TXSingletonH(Tools)

/// 根据数字判断颜色
/// @param value value
+ (NSColor *)colorOfValue:(NSString *)value;

/// 根据subValue 与 superValue 判断 大于就是红色 小于就是绿色
/// @param subValue 当前需要比较的数字
/// @param superValue 对比值
+ (NSColor*)colorOfSubValue:(double)subValue superValue:(double)superValue;

@end

NS_ASSUME_NONNULL_END
