
#import <NIMSDK/NIMSDK.h>
#import "NimConstant.h"

@interface Message: NSObject
{
@public NSString *messageId;
@public NSString *account;
@public NIMSessionType sessionType;
@public NIMMessage *message;
}
-(instancetype)initWithParams:(NSString *)id :(NSString *)account :(NIMSessionType)sessionType;
-(instancetype)initWithMessage:(NIMMessage *)message;
-(NSDictionary *)getMessage;
-(NIMMessage *)getImMessage;
@end
