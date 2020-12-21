//
//  ManagerFundViewController.h
//  FundLook
//
//  Created by yjs on 2020/12/21.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ManagerFundViewController : NSViewController

/// <#Description#>
/// @param nibNameOrNil <#nibNameOrNil description#>
/// @param nibBundleOrNil <#nibBundleOrNil description#>
/// @param managerType 1新增 2删除
- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managerType:(NSInteger)managerType;

@property (strong, nonatomic) NSDictionary *fundModel;

@end

NS_ASSUME_NONNULL_END
