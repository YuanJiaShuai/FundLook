//
//  FLTableView.m
//  FundLook
//
//  Created by yjs on 2020/12/17.
//

#import "FLTableView.h"

@implementation FLTableView

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (NSMenu *)menuForEvent:(NSEvent *)event{
    if(event.type == NSEventTypeRightMouseDown){
        NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        NSInteger row = [self rowAtPoint:menuPoint];
        self.menu.identifier = [NSString stringWithFormat:@"%ld", row];
        return self.menu;
    }else{
        return nil;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
