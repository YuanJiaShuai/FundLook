//
//  TodayViewController.m
//  FundLookWidget
//
//  Created by yjs on 2020/12/23.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "FMDBManager.h"
#import <AFNetworking.h>
#import "Tools.h"

@interface TodayViewController () <NCWidgetProviding>
@property (weak) IBOutlet NSTextField *yesterdayProfitLab;
@property (weak) IBOutlet NSTextField *todayProfitLab;

@end

@implementation TodayViewController

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    [self loadFundDataRequest];
    self.title = @"Hello World";
    completionHandler(NCUpdateResultNoData);
}

- (void)loadFundDataRequest{
    [[FMDBManager  sharedManager] loadAllFundData:^(NSMutableArray * _Nonnull result) {
        NSMutableString *fCodes = [[NSMutableString alloc]init];
        for(FundModel *model in result){
            if(fCodes.length == 0){
                [fCodes appendString:model.fundCode];
            }else{
                [fCodes appendFormat:@",%@", model.fundCode];
            }
        }
        
        [self requestFundDataWihtCodes:fCodes];
    }];
}

- (void)requestFundDataWihtCodes:(NSString *)fCodes{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",@"application/atom+xml",@"application/xml",@"text/xml,application/x-javascript",nil];
    
    NSString *url = [NSString stringWithFormat:@"https://fundmobapi.eastmoney.com/FundMNewApi/FundMNFInfo?pageIndex=1&pageSize=50&plat=Android&appType=ttjj&product=EFund&Version=1&deviceid=3f998f06-d80c-4eb7-988d-44da0f3a0841&Fcodes=%@", fCodes];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger TotalCount = [responseObject[@"TotalCount"] integerValue];
        if(TotalCount != 0){
            NSArray *diff = responseObject[@"Datas"];
            
            [self calculateTodayProfitWithFundArray:diff];
        }else{
            [self calculateTodayProfitWithFundArray:@[]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)calculateTodayProfitWithFundArray:(NSArray *)fundArray{
    __block CGFloat todayProfit = 0.0;
    __block CGFloat yestodyProfit = 0.0;
    
    NSMutableArray *fCodeArr = [[NSMutableArray alloc]init];
    for(NSDictionary *fundModel in fundArray){
        [fCodeArr addObject:fundModel[@"FCODE"]];
    }
    //146.69
    [[FMDBManager sharedManager] queryFundWithCodes:fCodeArr result:^(NSMutableArray * _Nonnull result) {
        for(FundModel *model in result){
            for(NSDictionary *fundModel in fundArray){
                if([model.fundCode isEqualToString:fundModel[@"FCODE"]]){
                    CGFloat netProfit = [fundModel[@"GSZ"] doubleValue] - [fundModel[@"NAV"] doubleValue];
                    todayProfit = todayProfit + [model.fFe doubleValue] * netProfit;
                    
                    CGFloat yesterdayNetProfit = [fundModel[@"NAV"] doubleValue] - [fundModel[@"NAV"] doubleValue]/(1 + ([fundModel[@"NAVCHGRT"] doubleValue]/100));
                    yestodyProfit = yestodyProfit + [model.fFe doubleValue] * yesterdayNetProfit;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *value = [NSString stringWithFormat:@"%0.2f", todayProfit];
            NSString *yesterdayValue = [NSString stringWithFormat:@"%0.2f", yestodyProfit];
            
            self.todayProfitLab.stringValue = value;
            self.todayProfitLab.textColor = [self colorOfValue:value];
        
            self.yesterdayProfitLab.stringValue = yesterdayValue;
            self.yesterdayProfitLab.textColor = [self colorOfValue:yesterdayValue];
        });
    }];
}

- (NSColor *)colorOfValue:(NSString *)value{
    value = [self stringOfObjc:value];
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

- (NSString *)stringOfObjc:(id)value{
    //处理null的情况
    if (value == nil || ([value class] == [NSNull class])) return @"--";
    //处理nsnumber的情况
    if ([value isKindOfClass:[NSNumber class]]) return [value description];
    //处理字符串为空的情况
    return [(NSString *)value length] >0 ? (NSString *)value : @"--";
}

- (IBAction)updateButtonClickEvent:(NSButton *)sender {
    [self loadFundDataRequest];
}

@end

