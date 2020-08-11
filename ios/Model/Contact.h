#import <NIMSDK/NIMSDK.h>

@interface Contact: NSObject
{
    @public NSString *contactId;
}
-(id)initWithId:(NSString *)contactId;
-(NSDictionary *)getContact;
@end
