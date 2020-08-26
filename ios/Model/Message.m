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

    if (message.messageType == NIMMessageTypeText) {

    }

    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    // 消息ID
    [messageDict setObject:message.messageId forKey:@"id"];
    // 会话ID
    [messageDict setObject:message.session.sessionId forKey:@"session_id"];
    // 会话类型
    [messageDict setObject:nimConstant->sessionType[message.session.sessionType] forKey:@"session_type"];
    // 发送方的帐号
    [messageDict setObject:message.from forKey:@"account"];
    // 发送者的昵称
    [messageDict setObject:contact[@"name"] forKey:@"nickname"];
    // 发送者头像
    [messageDict setObject:contact[@"avatar"] forKey:@"avatar"];
    // 消息文本
    [messageDict setObject:message.text ? message.text : @"" forKey:@"content"];
    // 回复时间
    [messageDict setObject:@(message.timestamp * 1000) forKey:@"time"];
    // 消息方向
    [messageDict setObject:message.isOutgoingMsg ? @"Out" : @"In" forKey:@"direct"];
    // 会话服务扩展字段
    [messageDict setObject:message.remoteExt == nil ? @"" : message.remoteExt forKey:@"extension"];
    // 消息类型
    [messageDict setObject:nimConstant->messageType[@(message.messageType)] forKey:@"type"];
    // 消息投递状态
    [messageDict setObject:nimConstant->deliveryState[message.deliveryState] forKey:@"status"];

    if (message.messageType == NIMMessageTypeImage) {
        NIMImageObject *image = message.messageObject;
        NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
        [imageDict setObject:image.thumbUrl ? image.thumbUrl : [NSNull null] forKey:@"thumb_url"];
        [imageDict setObject:image.url ? image.url : [NSNull null] forKey:@"url"];
        [imageDict setObject:image.displayName ? image.displayName : @"" forKey:@"display_name"];
        [imageDict setObject:@(image.size.width) forKey:@"width"];
        [imageDict setObject:@(image.size.height) forKey:@"height"];
        [messageDict setObject:imageDict forKey:@"image"];
    }

    return messageDict;
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
