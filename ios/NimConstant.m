#include "NimConstant.h"

@implementation NimConstant
- (instancetype)init {
    if (self = [super init]) {
        messageType = @{
            @0: @"text",
            @1: @"image",
            @2: @"audio",
            @3: @"video",
            @4: @"location",
            @5: @"notification",
            @6: @"file",
            @10: @"tip",
            @11: @"robot",
            @100: @"custom"
        };
        sessionType = @[@"P2P", @"Team", @"Chatroom", @"YSF", @"", @"SuperTeam"];
        deliveryState = @[@"fail", @"sending", @"success"];
        teamVerifyType = @[@"Free", @"Apply", @"Private"];
        teamNotifyType = @[@"All", @"Mute", @"Manager"];
    }
    return self;
}
@end
