#include "Contact.h"

@implementation Contact

-(instancetype)initWithId: (NSString *)id
{
    if (self = [super init]) {
        self->contactId = id;
    }
    return self;
}

-(NSDictionary *)getContact
{
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:self->contactId];
    __block NIMUserInfo *userInfo = user.userInfo;
    NSNull *null = [NSNull null];

    if (!userInfo) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [[NIMSDK sharedSDK].userManager fetchUserInfos:@[self->contactId] completion:^(NSArray *users, NSError *error) {
            NIMUser *nimUser = users[0];
            userInfo = nimUser.userInfo;
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }

    return @{
        @"account": user.userId,
        @"name": userInfo.nickName ? userInfo.nickName : null,
        @"avatar": userInfo.avatarUrl ? userInfo.avatarUrl : null,
        @"signature": userInfo.sign ? userInfo.sign : null,
        @"mobile": userInfo.mobile ? userInfo.mobile : null,
        @"gender": [@(userInfo.gender) stringValue],
        @"email": userInfo.email ? userInfo.email : null,
        @"birthday": userInfo.birth ? userInfo.birth : null
    };
}

@end
