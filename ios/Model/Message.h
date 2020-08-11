
#import <NIMSDK/NIMSDK.h>
#import "NimConstant.h"

@interface Message: NSObject
{
@public NSString *messageId;
@public NSString *account;
@public NIMSessionType sessionType;
}
-(instancetype)initWithParams:(NSString *)id :(NSString *)account :(NIMSessionType)sessionType;
-(NSDictionary *)getMessage;
@end
