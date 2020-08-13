#import "NeteaseIm.h"

@implementation NeteaseIm

NSDictionary *connectStatus;

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onConnectStatusChanged", @"onMessages", @"onConversationsChanged"];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSDictionary *)constantsToExport
{
    return @{
        @"sdkVersion": [NIMSDK sharedSDK].sdkVersion
    };
}

/**
 * SDK 初始化
 */
RCT_EXPORT_METHOD(init
                  :(nonnull NSString *)appKey
                  :(nonnull NSString *)apnsCername){
    //推荐在程序启动的时候初始化 NIMSDK
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername = apnsCername;
    [[NIMSDK sharedSDK] registerWithOption:option];

    // 添加监听
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];

    // 给连接状态赋值
    connectStatus = @{@"code": @"UNLOGIN", @"message": @"未登录/登录失败"};
}

/**
 * 手动登录
 */
RCT_EXPORT_METHOD(login
                  :(nonnull NSString *)account
                  :(nonnull NSString *)token
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    if ([[NIMSDK sharedSDK].loginManager isLogined]) {
        NSString *code = @"LOGINED";
        NSString *message = @"登录成功";
        return resolve(@{@"code": code, @"message": message});
    }

    [[NIMSDK sharedSDK].loginManager login:account token:token completion:^(NSError *error) {
        if (!error) {
            NSString *code = @"LOGINED";
            NSString *message = @"登录成功";

            // 设置用户信息
            NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
            [storage setValue:account forKey:@"account"];
            [storage setValue:token forKey:@"token"];
            [storage synchronize];

            resolve(@{@"code": code, @"message": message});
        }else{
            NSString *code = [@(error.code) stringValue];
            NSString *strEorr = @"登录失败";
            reject(code,strEorr, error);
            NSLog(@"%@:%@",strEorr,error);
        }
    }];
}

/**
 * 自动登录
 */
RCT_EXPORT_METHOD(autoLogin
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];

    NSString *account = [storage stringForKey:@"account"];
    NSString *token = [storage stringForKey:@"token"];

    if ([[NIMSDK sharedSDK].loginManager isLogined]) {
        return resolve(@(true));
    }

    if (account && token) {
        BOOL forcedMode = true;
        loginData.account = account;
        loginData.token = token;
        loginData.forcedMode = forcedMode;
        [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
        resolve(@(true));
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:-1 userInfo:@{
            NSLocalizedDescriptionKey:@"未能读取到用户token"
        }];
        reject(@"failed", @"用户已退出登录", error);
    }
}

/**
 * 是否登录
 */
RCT_EXPORT_METHOD(getLogined :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    BOOL isLogined = [[NIMSDK sharedSDK].loginManager isLogined];
    resolve(@(isLogined));
}

/**
 * 获取连接状态
 */
RCT_EXPORT_METHOD(getConnectStatus :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    resolve(connectStatus);
}

/**
 * 退出登录
 */
RCT_EXPORT_METHOD(logout) {
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error){
        //
    }];

    // 清除缓存的用户信息
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    [storage removeObjectForKey:@"account"];
    [storage removeObjectForKey:@"token"];
    [storage synchronize];
}

/**
 * 发送消息
 */
RCT_EXPORT_METHOD(sendMessage
                  :(nonnull NSString *)account
                  :(nonnull NSString *)text
                  :(nonnull NSString *)type
                  :(BOOL)resend
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    NIMSessionType sessionType = NIMSessionTypeP2P;

    NSArray *items = @[@"P2P", @"Team"];
    NSInteger index = [items indexOfObject:type];

    switch (index) {
        case NIMSessionTypeP2P:
            sessionType = NIMSessionTypeP2P;
            break;
        case NIMSessionTypeTeam:
            sessionType = NIMSessionTypeTeam;
            break;
        default:
            break;
    }

    // 构造出具体会话
    NIMSession *session = [NIMSession session:account type:sessionType];

    // 构造出具体消息
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = text;
    NSError *error = nil;

    // 发送消息
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];

    if (error) {
        reject(@"-1", @"消息发送失败", error);
        return;
    }

    resolve(@{@"code": @200, @"message": @"发送成功"});
}

/**
 * 最近会话
 */
RCT_EXPORT_METHOD(getConversations
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
    NSArray *conversations = [NimUtils getConversationsFromRecentSessions:recentSessions];

    resolve(conversations);
}

/**
 * 删除单条最近对话
 */
RCT_EXPORT_METHOD(deleteConversation
                  :(NSString *)conversationId
                  :(NSString *)sessionType){
    NimConstant *nimConstant = [[NimConstant alloc] init];
    NIMSessionType nimSessionType = [nimConstant->sessionType indexOfObject:sessionType];
    NIMSession *session = [NIMSession session:conversationId type:nimSessionType];

    NIMRecentSession *recentSession = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    [[NIMSDK sharedSDK].conversationManager deleteRecentSession:recentSession];
}

/**
 * 获取联系人信息
 */
RCT_EXPORT_METHOD(getContact
                  :(NSString *)account
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    Contact *contact = [[Contact alloc] initWithId:account];
    resolve(contact.getContact);
}

/**
 * 获取群信息
 */
RCT_EXPORT_METHOD(getTeam
                  :(NSString *)teamId
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    Team *team = [[Team alloc] initWithId:teamId];
    resolve(team.getTeam);
}

/**
 * 获取我的群
 */
RCT_EXPORT_METHOD(getTeams
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    NSMutableArray *teams = [[NSMutableArray alloc]init];
    for (NIMTeam *nimTeam in [NIMSDK sharedSDK].teamManager.allMyTeams) {
        NSDictionary *team = [[Team alloc] initWithTeam:nimTeam].getTeam;
        [teams addObject:team];
    }
    resolve(teams);
}

/**
 * 获取单个消息
 */
RCT_EXPORT_METHOD(getMessage
                  :(NSString *)messageId
                  :(NSString *)account
                  :(NSString *)sessionType
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    NimConstant *nimConstant = [[NimConstant alloc] init];
    NIMSessionType nimSessionType = [nimConstant->sessionType indexOfObject:sessionType];
    Message *message = [[Message alloc] initWithParams:messageId :account :nimSessionType];
    resolve(message.getMessage);
}

/**
 * 获取单个消息
 */
RCT_EXPORT_METHOD(getHistoryMessages
                  :(NSString *)sessionId
                  :(NSString *)sessionType
                  :(NSString *)messageId
                  :(int)limitCount
                  :(BOOL)asc
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject){
    NIMMessage *anchor = nil;
    NimConstant *nimConstant = [[NimConstant alloc] init];
    NIMSessionType nimSessionType = [nimConstant->sessionType indexOfObject:sessionType];

    if (messageId.length > 0) {
        anchor = [[Message alloc] initWithParams:messageId :sessionId :nimSessionType].getImMessage;
    }

    // 构造一个 session
    NIMSession *session = [NIMSession session:sessionId type:nimSessionType];

    NSArray<NIMMessage *> *nimMessages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session message:anchor limit:limitCount];
    NSMutableArray *messages = [[NSMutableArray alloc]init];

    for (NIMMessage *nimMessage in nimMessages) {
        NSDictionary *message = [[Message alloc] initWithMessage:nimMessage].getMessage;
        [messages addObject:message];
    }

    resolve(messages);
}

/**
 *  连接状态事件
 *  @param step 登录步骤
 *  @discussion 这个回调主要用于客户端UI的刷新
 */
- (void)onLogin :(NIMLoginStep)step{
    NSDictionary *status = [NimUtils getConnectStatus:(step)];
    connectStatus = status;
    [self sendEventWithName:@"onConnectStatusChanged" body:status];
}

/**
 * 消息事件
 * @param imMessages 消息
 */
- (void)onRecvMessages:(NSArray<NIMMessage *> *)imMessages{
    NSMutableArray *messages = [NSMutableArray array];

    for (int i = 0; i < imMessages.count; i++) {
        NIMMessage *imMessage = imMessages[i];
        Message *message = [[Message alloc] initWithParams:imMessage.messageId :imMessage.from :imMessage.session.sessionType];
        messages[i] = message.getMessage;
    }

    [self sendEventWithName:@"onMessages" body:messages];
}

/**
 * 监听最近对话变更
 */
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
        NSArray *conversations = [NimUtils getConversationsFromRecentSessions:recentSessions];

        [self sendEventWithName:@"onConversationsChanged" body:conversations];
    });
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
        NSArray *conversations = [NimUtils getConversationsFromRecentSessions:recentSessions];

        [self sendEventWithName:@"onConversationsChanged" body:conversations];
    });
}

- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *recentSessions = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
        NSArray *conversations = [NimUtils getConversationsFromRecentSessions:recentSessions];
        [self sendEventWithName:@"onConversationsChanged" body:conversations];
    });
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
}

@end
