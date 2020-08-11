#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <NIMSDK/NIMSDK.h>
#import <NIMSDK/NIMLoginManagerProtocol.h>
#import "NimUtils.h"
#import "NimConstant.h"
#import "Model/Contact.h"
#import "Model/Team.h"
#import "Model/Message.h"

@interface NeteaseIm : RCTEventEmitter <NIMLoginManagerDelegate,NIMChatManagerDelegate,NIMConversationManagerDelegate,RCTBridgeModule>

@property (nonatomic,strong) NSDictionary *connectStatus;

- (void)onLogin:(NIMLoginStep)step;
- (void)onRecvMessages:(NSArray<NIMMessage *> *)imMessages;
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount;
- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount;
- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount;
@end
