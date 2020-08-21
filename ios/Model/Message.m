#include "Message.h"

@implementation Message

-(instancetype)initWithParams:(NSString *)id :(NSString *)account :(NIMSessionType)sessionType
{
    if (self = [super init]) {
        self->messageId = id;
        self->account = account;
        self->sessionType = sessionType;
    }
    return self;
}

-(instancetype)initWithMessage:(NIMMessage *)message
{
    if (self = [super init]) {
        self->message = message;
    }
    return self;
}

-(NSDictionary *)getMessage
{
    NIMMessage *message = self->message;
    NimConstant *nimConstant = [[NimConstant alloc] init];

    if (!message) {
        NIMSession *session = [NIMSession session:self->account type:self->sessionType];
        NSArray<NIMMessage *> *nimMessages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session messageIds:@[self->messageId]];
        message = nimMessages.count > 0 ? nimMessages[0] : nil;
    }

    if (!message) {
        return nil;
    }

    NSDictionary *contact = [[Contact alloc] initWithId:message.from].getContact;

    NSDictionary *dict = @{
        // 消息ID
        @"id": message.messageId,
        // 会话ID
        @"session_id": message.session.sessionId,
        // 会话类型
        @"session_type": nimConstant->sessionType[message.session.sessionType],
        // 发送方的帐号
        @"account": message.from,
        // 发送者的昵称
        @"nickname": contact[@"name"],
        // 发送者头像
        @"avatar": contact[@"avatar"],
        // 消息文本
        @"content": message.text ? message.text : @"",
        // 回复时间
        @"time": @(message.timestamp * 1000),
        // 消息方向
        @"direct": message.isOutgoingMsg ? @"Out" : @"In",
        // 会话服务扩展字段
        @"extension": message.localExt == nil ? @"" : message.localExt,
        // 消息类型
        @"type": nimConstant->messageType[@(message.messageType)],
        // 消息投递状态
        @"status": nimConstant->deliveryState[message.deliveryState],
    };

    return dict;
}

-(NIMMessage *)getImMessage
{
    NIMMessage *message = self->message;

    if (!message) {
        NIMSession *session = [NIMSession session:self->account type:self->sessionType];
        NSArray<NIMMessage *> *nimMessages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session messageIds:@[self->messageId]];
        message = nimMessages.count > 0 ? nimMessages[0] : nil;
    }

    return message;
}

@end
