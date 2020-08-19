#import "NimUtils.h"

@implementation NimUtils
/**
 *  获取连接状态
 *  @param step 登录步骤
 */
+ (NSDictionary *) getConnectStatus: (NIMLoginStep)step{
    NSString *code = @"";
    NSString *message = @"";

    switch (step) {
        case NIMLoginStepLinking:
            code = @"CONNECTING";
            message = @"连接服务器";
            break;
        case NIMLoginStepLinkOK:
            code = @"CONNECTED";
            message = @"连接服务器成功";
            break;
        case NIMLoginStepLinkFailed:
            code = @"CONNECT_FAILED";
            message = @"连接服务器失败";
            break;
        case NIMLoginStepLogining:
            code = @"LOGINING";
            message = @"登录中";
            break;
        case NIMLoginStepLoginOK:
            code = @"LOGINED";
            message = @"登录成功";
            break;
        case NIMLoginStepLoginFailed:
            code = @"UNLOGIN";
            message = @"未登录/登录失败";
            break;
        case NIMLoginStepSyncing:
            code = @"SYNCING";
            message = @"开始同步数据";
            break;
        case NIMLoginStepSyncOK:
            code = @"SYNCED";
            message = @"同步数据完成";
            break;
        case NIMLoginStepLoseConnection:
            code = @"NET_BROKEN";
            message = @"连接断开";
            break;
        case NIMLoginStepNetChanged:
            code = @"NET_CHANGED";
            message = @"网络切换";
            break;
        default:
            break;
    }

    NSDictionary *dict = @{@"code" : code, @"message" : message};

    return dict;
}

+ (NSArray *) getConversationsFromRecentSessions: (NSArray *)recentSessions {
    NSMutableArray *conversations = [NSMutableArray array];
    NimConstant *nimConstant = [[NimConstant alloc] init];

    for (int i = 0; i < recentSessions.count; i++) {
        NIMRecentSession *recentSession = recentSessions[i];
        NSString *id = recentSession.session.sessionId;

        NSMutableDictionary *conversation = [[NSMutableDictionary alloc] init];
        NSDictionary *message = [[Message alloc] initWithMessage: recentSession.lastMessage].getMessage;
        NSString *extension = recentSession.serverExt == nil ? @"" : recentSession.serverExt;

        [conversation setObject:id forKey:@"id"];
        [conversation setObject:nimConstant->sessionType[recentSession.session.sessionType] forKey:@"type"];
        [conversation setObject:@(recentSession.unreadCount) forKey:@"unread_count"];
        [conversation setObject:message forKey:@"last_message"];
        [conversation setObject:extension forKey:@"extension"];

        if (recentSession.session.sessionType == NIMSessionTypeP2P) {
            NSDictionary *contact = [[Contact alloc] initWithId:id].getContact;
            if (contact) {
                [conversation setObject:contact[@"avatar"] forKey:@"avatar"];
                [conversation setObject:contact[@"name"] forKey:@"name"];
            }
        }

        if (recentSession.session.sessionType == NIMSessionTypeTeam) {
            NSDictionary *team = [[Team alloc] initWithId:id].getTeam;

            [conversation setValue:team[@"avatar"] forKey:@"avatar"];
            [conversation setObject:team[@"name"] forKey:@"name"];
            [conversation setObject:team[@"notify_type"] forKey:@"notify_type"];
            [conversation setObject:team[@"verify_type"] forKey:@"verify_type"];
        }

        conversations[i] = conversation;
    }

    return conversations;
}
@end
