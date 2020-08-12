#include "NimConstant.h"

@implementation NimConstant
- (instancetype)init {
    if (self = [super init]) {
        messageType = @[@"text", @"image", @"audio", @"video", @"location",@"notification", @"file", @"tip", @"robot", @"custom"];
        sessionType = @[@"P2P", @"Team", @"Chatroom", @"YSF", @"", @"SuperTeam"];
        deliveryState = @[@"fail", @"sending", @"success"];
        verifyType = @[@"Free", @"Apply", @"Private"];
        notifyType = @[@"All", @"Mute", @"Manager"];
    }
    return self;
}
@end