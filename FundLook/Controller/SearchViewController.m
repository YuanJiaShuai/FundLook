//
//  SearchViewController.m
//  FundLook
//
//  Created by yjs on 2020/12/17.
//

#import "SearchViewController.h"
#import <WebKit/WKWebView.h>
#import "Tools.h"
#import "ManagerFundViewController.h"

@interface SearchViewController ()<NSSearchFieldDelegate>
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSButton *searchBtn;
@property (strong, nonatomic) NSString *userAgent;
@property (weak) IBOutlet NSTableView *tableView;
@property (strong, nonatomic) NSArray *searchArr;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    if (@available(macOS 10.11, *)) {
        self.searchField.delegate = self;
    } else {
        // Fallback on earlier versions
    }
    
    WKWebView  *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *oldUserAgent = result;
        NSString *newUserAgent = [NSString stringWithFormat:@"%@ %@",oldUserAgent,@"DuBanUserAgent/v1.6"];
        if (@available(macOS 10.11, *)) {
            wkWebView.customUserAgent = newUserAgent;
        } else {
            // Fallback on earlier versions
        }
        
        self.userAgent = oldUserAgent.length != 0 ? oldUserAgent : newUserAgent;
    }];
}

- (IBAction)searchButtonClickEvent:(NSButton *)sender {
    if(self.searchField.stringValue.length != 0 && self.userAgent.length != 0){
        [self sendSearchRequest];
    }
}

- (void)sendSearchRequest{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",@"application/atom+xml",@"application/xml",@"text/xml,application/x-javascript",nil];
    
    [manager.requestSerializer setValue:@"fundsuggest.eastmoney.com" forHTTPHeaderField:@"Host"];
    [manager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [manager.requestSerializer setValue:@"zh-CN,zh;q=0.9" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setValue:@"https://fund.eastmoney.com/" forHTTPHeaderField:@"Referer"];
    [manager.requestSerializer setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"script" forHTTPHeaderField:@"Sec-Fetch-Dest"];
    
    NSString *url = [[NSString stringWithFormat:@"https://fundsuggest.eastmoney.com/FundSearch/api/FundSearchAPI.ashx?m=1&key=%@", self.searchField.stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger ErrCode = [responseObject[@"ErrCode"] integerValue];
        if(ErrCode == 0){
            NSArray *Datas = responseObject[@"Datas"];
            self.searchArr = Datas;
            [self.tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (IBAction)cancelButtonClickEvent:(NSButton *)sender {
    [self dismissViewController:self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.searchArr.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary *fundModel = self.searchArr[row];
    NSDictionary *FundBaseInfo = fundModel[@"FundBaseInfo"];
    
    if (tableColumn == tableView.tableColumns[0]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@ [%@]", fundModel[@"NAME"], fundModel[@"CODE"]];
        return cell;
    }else if(tableColumn == tableView.tableColumns[1]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
        if([FundBaseInfo isKindOfClass:[NSDictionary class]] && [FundBaseInfo.allKeys containsObject:@"DWJZ"]){
            cell.textField.stringValue = [NSString stringWithFormat:@"%@", FundBaseInfo[@"DWJZ"]];
        }else{
            cell.textField.stringValue = @"--";
        }
        return cell;
    }else if(tableColumn == tableView.tableColumns[2]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        if([FundBaseInfo isKindOfClass:[NSDictionary class]] && [FundBaseInfo.allKeys containsObject:@"FTYPE"]){
            cell.textField.stringValue = [NSString stringWithFormat:@"%@", FundBaseInfo[@"FTYPE"]];
        }else{
            cell.textField.stringValue = @"--";
        }
        return cell;
    }else if(tableColumn == tableView.tableColumns[3]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell4" owner:nil];
        if([FundBaseInfo isKindOfClass:[NSDictionary class]] && [FundBaseInfo.allKeys containsObject:@"JJJL"]){
            cell.textField.stringValue = [NSString stringWithFormat:@"%@", FundBaseInfo[@"JJJL"]];
        }else{
            cell.textField.stringValue = @"--";
        }
        return cell;
    }else{
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell5" owner:nil];
        NSButton *button = [cell viewWithTag:9];
        button.identifier = [NSString stringWithFormat:@"%ld", row];
        return cell;
    }
}

- (IBAction)addButtonClickEvent:(NSButton *)sender {
    NSDictionary *fundModel = self.searchArr[[sender.identifier integerValue]];
    
    FundModel *model = [[FundModel alloc]init];
    model.fundCode = fundModel[@"CODE"];
    [[FMDBManager sharedManager] existWithfCode:fundModel[@"CODE"] result:^(BOOL exist) {
        if(exist){
            //判断是否存在自选
            ManagerFundViewController *fundVc = [[ManagerFundViewController alloc]initWithNibName:@"ManagerFundViewController" bundle:[NSBundle mainBundle] managerType:2];
            fundVc.fundModel = fundModel;
            [self presentViewControllerAsSheet:fundVc];
        }else{
            ManagerFundViewController *fundVc = [[ManagerFundViewController alloc]initWithNibName:@"ManagerFundViewController" bundle:[NSBundle mainBundle] managerType:1];
            fundVc.fundModel = fundModel;
            [self presentViewControllerAsSheet:fundVc];
        }
    }];
}

- (void)controlTextDidChange:(NSNotification *)obj{
    [self sendSearchRequest];
}
@end
