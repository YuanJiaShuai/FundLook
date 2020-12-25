//
//  Tools.m
//  FundLook
//
//  Created by yjs on 2020/12/17.
//

#import "Tools.h"

@implementation Tools
TXSingletonM(Tools)

+ (NSColor *)colorOfValue:(NSString *)value{
    value = [Tools stringOfObjc:value];
    if([value isEqualToString:@"--"]){
        return [NSColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
    }else{
        if([value doubleValue] > 0){
            return [NSColor colorWithRed:244.0/255 green:67.0/255 blue:54.0/255 alpha:1];
        }else if([value doubleValue] < 0){
            return [NSColor colorWithRed:32.0/255 green:171.0/255 blue:63.0/255 alpha:1];
        }else{
            return [NSColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
        }
    }
}

+ (NSColor*)colorOfSubValue:(double)subValue superValue:(double)superValue{
    if(subValue > superValue){
        return [NSColor colorWithRed:244.0/255 green:67.0/255 blue:54.0/255 alpha:1];
    }else if(subValue < superValue){
        return [NSColor colorWithRed:32.0/255 green:171.0/255 blue:63.0/255 alpha:1];
    }else{
        return [NSColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
    }
}

+ (NSString *)stringOfObjc:(id)value{
    //处理null的情况
    if (value == nil || ([value class] == [NSNull class])) return @"--";
    //处理nsnumber的情况
    if ([value isKindOfClass:[NSNumber class]]) return [value description];
    //处理字符串为空的情况
    return [(NSString *)value length] >0 ? (NSString *)value : @"--";
}

@end
