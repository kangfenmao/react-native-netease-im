#import <NIMSDK/NIMSDK.h>
#import <NIMSDK/NIMLoginManagerProtocol.h>
#import "NimConstant.h"
#import "Model/Contact.h"
#import "Model/Team.h"
#import "Model/Message.h"

@interface NimUtils: NSObject
+ (NSDictionary *) getConnectStatus: (NIMLoginStep)step;
+ (NSArray *) getConversationsFromRecentSessions: (NSArray *)recentSessions;
@end
