//
//  AppDelegate.m
//  FundLook
//
//  Created by yjs on 2020/12/16.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

//启动
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSMenuItem *item = NSApp.mainMenu.itemArray.firstObject;
    
    NSMenuItem *quitItem = item.submenu.itemArray.lastObject;
    quitItem.target = self;
    quitItem.action = @selector(customQuit);
}

//退出
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (void)customQuit {
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = @"确认退出";
    [alert addButtonWithTitle:@"确认"];
    [alert addButtonWithTitle:@"取消"];
    [alert beginSheetModalForWindow:NSApp.keyWindow completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            [NSApp terminate:nil];
        }
    }];
}

@end
