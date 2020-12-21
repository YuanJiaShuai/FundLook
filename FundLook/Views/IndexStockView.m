//
//  IndexStockView.m
//  FundLook
//
//  Created by yjs on 2020/12/17.
//

#import "IndexStockView.h"
#import "Tools.h"

@interface IndexStockView()

/// 股票名称
@property (strong, nonatomic) NSTextField *nameText;

/// 最新价
@property (strong, nonatomic) NSTextField *priceText;

/// 涨跌额
@property (strong, nonatomic) NSTextField *leftText;

/// 涨跌幅
@property (strong, nonatomic) NSTextField *rightText;

@end

@implementation IndexStockView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self addSubview:self.nameText];
    [self addSubview:self.priceText];
    [self addSubview:self.leftText];
    [self addSubview:self.rightText];
}

- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if(self){
        [self addSubview:self.nameText];
        [self addSubview:self.priceText];
        [self addSubview:self.leftText];
        [self addSubview:self.rightText];
    }
    return self;
}

- (void)setRealtime:(NSDictionary *)realtime{
    if(realtime && [realtime isKindOfClass:[NSDictionary class]]){
        self.nameText.stringValue = realtime[@"f14"];
        
        NSColor *valueColor = [Tools colorOfValue:realtime[@"f4"]];
        self.priceText.stringValue = [NSString stringWithFormat:@"%0.2f", [realtime[@"f2"] doubleValue]];
        self.priceText.textColor = valueColor;
        
        self.leftText.stringValue = [NSString stringWithFormat:@"%0.2f", [realtime[@"f4"] doubleValue]];
        self.leftText.textColor = valueColor;
        
        self.rightText.stringValue = [NSString stringWithFormat:@"%0.2f%%", [realtime[@"f3"] doubleValue]];
        self.rightText.textColor = valueColor;
    }
}

- (BOOL)isFlipped{
    return YES;
}

- (void)layout{
    [super layout];
    [self.nameText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(@(16));
    }];
    
    [self.priceText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.nameText.mas_bottom).offset(8);
    }];
    
    [@[self.leftText, self.rightText] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:8 leadSpacing:8 tailSpacing:8];
    
    [@[self.leftText, self.rightText] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceText.mas_bottom).offset(8);
    }];
}

- (NSTextField *)nameText{
    if(!_nameText){
        _nameText = [[NSTextField alloc]init];
        _nameText.textColor = [NSColor blackColor];
        _nameText.font = font_PingFangM(16);
        _nameText.stringValue = @"--";
        _nameText.alignment = NSTextAlignmentCenter;
        _nameText.backgroundColor = [NSColor clearColor];
        _nameText.editable = NO;
        _nameText.bordered = NO;
    }
    return _nameText;
}

- (NSTextField *)priceText{
    if(!_priceText){
        _priceText = [[NSTextField alloc]init];
        _priceText.textColor = [NSColor blackColor];
        _priceText.font = font_DR(16);
        _priceText.stringValue = @"--";
        _priceText.alignment = NSTextAlignmentCenter;
        _priceText.backgroundColor = [NSColor clearColor];
        _priceText.editable = NO;
        _priceText.bordered = NO;
    }
    return _priceText;
}

- (NSTextField *)leftText{
    if(!_leftText){
        _leftText = [[NSTextField alloc]init];
        _leftText.textColor = [NSColor blackColor];
        _leftText.font = font_DR(15);
        _leftText.stringValue = @"--";
        _leftText.alignment = NSTextAlignmentRight;
        _leftText.backgroundColor = [NSColor clearColor];
        _leftText.editable = NO;
        _leftText.bordered = NO;
    }
    return _leftText;
}

- (NSTextField *)rightText{
    if(!_rightText){
        _rightText = [[NSTextField alloc]init];
        _rightText.textColor = [NSColor blackColor];
        _rightText.font = font_DR(15);
        _rightText.stringValue = @"--";
        _rightText.alignment = NSTextAlignmentLeft;
        _rightText.backgroundColor = [NSColor clearColor];
        _rightText.editable = NO;
        _rightText.bordered = NO;
    }
    return _rightText;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
