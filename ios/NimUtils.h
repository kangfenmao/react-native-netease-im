#import <NIMSDK/NIMSDK.h>
#import <NIMSDK/NIMLoginManagerProtocol.h>
#import "Model/Contact.h"
#import "NimConstant.h"
#import "Model/Team.h"

@interface NimUtils: NSObject
+ (NSDictionary *) getConnectStatus: (NIMLoginStep)step;
+ (NSArray *) getConversationsFromRecentSessions: (NSArray *)recentSessions;
@end
