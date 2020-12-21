//
//  ManagerFundViewController.m
//  FundLook
//
//  Created by yjs on 2020/12/21.
//

#import "ManagerFundViewController.h"

@interface ManagerFundViewController ()
@property (weak) IBOutlet NSTextField *titleLab;
@property (weak) IBOutlet NSTextField *feTextField;
@property (weak) IBOutlet NSButton *okButton;

@property (assign, nonatomic) NSInteger managerType;

@end

@implementation ManagerFundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    if(self.managerType == 1){//新增
        self.titleLab.stringValue = @"添加当前基金，请输入您的持有份额，方便盘中估算您的收益，如果不添加，默认份额为0";
        self.feTextField.hidden = NO;
    }else if(self.managerType == 2){//删除
        self.titleLab.stringValue = @"当前基金已经存在您的自选列表中，您确定要执行删除操作吗？";
        self.feTextField.hidden = YES;
    }else{
        self.titleLab.stringValue = @"Error";
        self.feTextField.hidden = YES;
    }
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managerType:(NSInteger)managerType{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.managerType = managerType;
    }
    return self;
}

- (IBAction)cancelButtonClickEvent:(NSButton *)sender {
    [self dismissViewController:self];
}

- (IBAction)okButtonClickEvent:(NSButton *)sender {
    FundModel *model = [[FundModel alloc]init];
    model.fundCode = self.fundModel[@"CODE"];
    model.fFe = self.feTextField.stringValue;
    if(self.managerType == 1){
        [[FMDBManager sharedManager] addFundModel:model];
    }else if(self.managerType == 2){
        [[FMDBManager sharedManager] delFundModel:model];
    }
    [self dismissViewController:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOptionalFundUINotification" object:nil];
}

@end
