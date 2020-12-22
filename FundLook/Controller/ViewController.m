//
//  ViewController.m
//  FundLook
//
//  Created by yjs on 2020/12/16.
//

#import "ViewController.h"
#import "IndexStockView.h"
#import "Tools.h"
#import "SearchViewController.h"
#import "FundDetailViewController.h"

@interface ViewController()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet IndexStockView *shangzhengStockView;
@property (weak) IBOutlet IndexStockView *shenzhengStockView;
@property (weak) IBOutlet IndexStockView *chuangyeStockView;

@property (weak) IBOutlet NSTableView *tableView;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSMutableArray *fundArray;
@property (weak) IBOutlet NSTextField *todayProfitLab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(requestIndexData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
    
    [self loadFundDataRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFundDataRequest) name:@"UpdateOptionalFundUINotification" object:nil];
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

- (void)requestIndexData{
    //获取指数数据
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",@"application/atom+xml",@"application/xml",@"text/xml,application/x-javascript",nil];
    
    [manager GET:@"https://push2.eastmoney.com/api/qt/ulist.np/get?fltt=2&fields=f2,f3,f4,f12,f14&secids=1.000001,0.399001,0.399006" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *diff = responseObject[@"data"][@"diff"];
        [diff enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx == 0){
                self.shangzhengStockView.realtime = obj;
            }else if(idx == 1){
                self.shenzhengStockView.realtime = obj;
            }else if(idx == 2){
                self.chuangyeStockView.realtime = obj;
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
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
//            for(NSDictionary *diffDic in diff){
//                FundModel *model = [[FundModel alloc]init];
//                model.fundCode = diffDic[@"FCODE"];
//
//                [[FMDBManager sharedManager] updateFundModel:model];
//            }
            self.fundArray = [[NSMutableArray alloc]initWithArray:diff];
            [self.tableView reloadData];
            
            [self calculateTodayProfitWithFundArray:self.fundArray];
        }else{
            self.fundArray = [[NSMutableArray alloc]init];
            [self.tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)calculateTodayProfitWithFundArray:(NSArray *)fundArray{
    __block CGFloat todayProfit = 0.0;
    
    NSMutableArray *fCodeArr = [[NSMutableArray alloc]init];
    for(NSDictionary *fundModel in fundArray){
        [fCodeArr addObject:fundModel[@"FCODE"]];
    }
    
    [[FMDBManager sharedManager] queryFundWithCodes:fCodeArr result:^(NSMutableArray * _Nonnull result) {
        for(FundModel *model in result){
            for(NSDictionary *fundModel in fundArray){
                if([model.fundCode isEqualToString:fundModel[@"FCODE"]]){
                    CGFloat netProfit = [fundModel[@"GSZ"] doubleValue] - [fundModel[@"NAV"] doubleValue];
                    todayProfit = todayProfit + [model.fFe doubleValue] * netProfit;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *value = [NSString stringWithFormat:@"%0.2f", todayProfit];
            self.todayProfitLab.stringValue = value;
            self.todayProfitLab.textColor = [Tools colorOfValue:value];
        });
    }];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.fundArray.count;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    return YES;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary *fundModel = self.fundArray[row];
    tableView.menu.identifier = [NSString stringWithFormat:@"%ld", row];
    if (tableColumn == tableView.tableColumns[0]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@ [%@]", fundModel[@"SHORTNAME"], fundModel[@"FCODE"]];
        return cell;
    }else if(tableColumn == tableView.tableColumns[1]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@%%", fundModel[@"GSZZL"]];
        cell.textField.textColor = [Tools colorOfValue:fundModel[@"GSZZL"]];
        return cell;
    }else if(tableColumn == tableView.tableColumns[2]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
        cell.textField.stringValue = fundModel[@"GSZ"];
        cell.textField.textColor = [Tools colorOfValue:fundModel[@"GSZZL"]];
        return cell;
    }else if(tableColumn == tableView.tableColumns[3]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell4" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@  %@%%", fundModel[@"NAV"], fundModel[@"NAVCHGRT"]];
        cell.textField.textColor = [Tools colorOfValue:fundModel[@"NAVCHGRT"]];
        return cell;
    }else{
        //显示份额
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell5" owner:nil];
        [[FMDBManager sharedManager] queryFundWithCodes:@[fundModel[@"FCODE"]] result:^(NSMutableArray * _Nonnull result) {
            if(result.count > 0){
                FundModel *fModel = [result firstObject];
                cell.textField.stringValue = [NSString stringWithFormat:@"%0.2f", [fModel.fFe doubleValue]];
            }
        }];
        
        return cell;
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj{
    NSTextField *tf = obj.object;
    NSTableCellView *cellView = (NSTableCellView *)[tf superview];
    NSTableRowView *rowView = (NSTableRowView *)[cellView superview];
    NSInteger row = [self.tableView rowForView: rowView];
    
    NSDictionary *fundModel = self.fundArray[row];
    
    [[FMDBManager sharedManager] queryFundWithCodes:@[fundModel[@"FCODE"]] result:^(NSMutableArray * _Nonnull result) {
        if(result.count > 0){
            FundModel *fModel = [result firstObject];
            fModel.fFe = tf.stringValue;
            [[FMDBManager sharedManager] updateFundModel:fModel];
        }
    }];
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    
}

- (IBAction)updateFundClickEvent:(NSButton *)sender {
    [self loadFundDataRequest];
}

- (void)rightMouseUp:(NSEvent *)event{
    
}

- (IBAction)deleteOptionFundEvent:(NSMenuItem *)sender {
    
    NSDictionary *fundModel = self.fundArray[[sender.menu.identifier integerValue]];
    
    FundModel *model = [[FundModel alloc]init];
    model.fundCode = fundModel[@"FCODE"];
    [[FMDBManager sharedManager] delFundModel:model];
    
    [self loadFundDataRequest];
}

- (IBAction)lookDetailFundEvent:(NSMenuItem *)sender {
    NSDictionary *fundModel = self.fundArray[[sender.menu.identifier integerValue]];
    FundDetailViewController *vc = [[FundDetailViewController alloc]initWithNibName:@"FundDetailViewController" bundle:nil];
    vc.fCode = fundModel[@"FCODE"];
    [self presentViewControllerAsModalWindow:vc];
    NSLog(@"");
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


@end
