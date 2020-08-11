#import <NIMSDK/NIMSDK.h>

@interface Team: NSObject
{
@public NSString *teamId;
}
-(id)initWithId:(NSString *)teamId;
-(NSDictionary *)getTeam;
@end
