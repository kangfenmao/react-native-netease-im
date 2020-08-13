#import <Foundation/Foundation.h>
#include "Team.h"

@implementation Team

-(instancetype)initWithId: (NSString *)teamId
{
    if (self = [super init]) {
        self->teamId = teamId;
    }
    return self;
}

-(instancetype)initWithTeam: (NIMTeam *)team
{
    if (self = [super init]) {
        self->team = team;
    }
    return self;
}

-(NSDictionary *)getTeam
{
    __block NIMTeam *team = self->team ? self->team : [[NIMSDK sharedSDK].teamManager teamById:self->teamId];
    NimConstant *nimConstant = [[NimConstant alloc] init];

    if (!team) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [[NIMSDK sharedSDK].teamManager fetchTeamInfo:self->teamId completion:^(NSError * _Nullable error, NIMTeam * _Nullable nimTeam) {
            if (error) {
                dispatch_semaphore_signal(semaphore);
                return;
            }
            team = nimTeam;
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }

    if (!team) {
        return nil;
    }

    return @{
        @"id": team.teamId,
        @"name": team.teamName ? team.teamName : [NSNull null],
        @"avatar": team.avatarUrl ? team.avatarUrl : [NSNull null],
        @"type": @(team.type),
        @"creator": team.owner ? team.owner : [NSNull null],
        @"announcement": team.announcement ? team.announcement : [NSNull null],
        @"introduce": team.intro ? team.intro : [NSNull null],
        @"member_count": @(team.memberNumber),
        @"member_limit": @(team.level),
        @"notify_type": nimConstant->teamNotifyType[team.notifyStateForNewMsg],
        @"verify_type": nimConstant->teamVerifyType[team.joinMode],
        @"create_time": [@(team.createTime * 1000) stringValue]
    };
}

@end
