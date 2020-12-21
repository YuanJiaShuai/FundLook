//
//  Tools.m
//  FundLook
//
//  Created by yjs on 2020/12/17.
//

#import "Tools.h"

#define TXCOLORBLACK [NSColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1]
#define TXCOLORRED [NSColor colorWithRed:244.0/255 green:67.0/255 blue:54.0/255 alpha:1]
#define TXCOLORGREEN [NSColor colorWithRed:32.0/255 green:171.0/255 blue:63.0/255 alpha:1]

@implementation Tools
TXSingletonM(Tools)

+ (NSColor *)colorOfValue:(NSString *)value{
    value = [Tools stringOfObjc:value];
    if([value isEqualToString:@"--"]){
        return TXCOLORBLACK;
    }else{
        if([value doubleValue] > 0){
            return TXCOLORRED;
        }else if([value doubleValue] < 0){
            return TXCOLORGREEN;
        }else{
            return TXCOLORBLACK;
        }
    }
}

+ (NSColor*)colorOfSubValue:(double)subValue superValue:(double)superValue{
    if(subValue > superValue){
        return TXCOLORRED;
    }else if(subValue < superValue){
        return TXCOLORGREEN;
    }else{
        return TXCOLORBLACK;
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
