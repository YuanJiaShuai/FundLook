//
//  FundDetailViewController.m
//  FundLook
//
//  Created by yjs on 2020/12/21.
//

#import "FundDetailViewController.h"
#import <WebKit/WKWebView.h>

@interface FundDetailViewController ()

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation FundDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.webView = [[WKWebView alloc]init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://fund.eastmoney.com/%@.html", self.fCode]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(@(0));
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"title"]) {
        NSString *titleStr = self.webView.title;
        self.title = titleStr;
    }
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"title"];
}
@end
