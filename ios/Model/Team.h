#import <NIMSDK/NIMSDK.h>
#import "NimConstant.h"

@interface Team: NSObject
{
@public NSString *teamId;
@public NIMTeam *team;
}
-(instancetype)initWithId:(NSString *)teamId;
-(instancetype)initWithTeam: (NIMTeam *)team;
-(NSDictionary *)getTeam;
@end
