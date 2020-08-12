package com.kangfenmao.nim.model;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.team.TeamService;

public class Team {
  String id;
  com.netease.nimlib.sdk.team.model.Team team;
  TeamService teamService =  NIMClient.getService(TeamService.class);;

  public Team(String id) {
    this.id = id;
    this.team = this.teamService.queryTeamBlock(this.id);
  }

  public Team(com.netease.nimlib.sdk.team.model.Team team) {
    this.team = team;
  }

  public WritableMap getTeam() {
    WritableMap map = Arguments.createMap();

    if (this.team == null) {
      return null;
    }

    map.putString("id", team.getId());
    map.putString("name", team.getName());
    map.putString("avatar", team.getIcon());
    map.putString("type", String.valueOf(team.getType()));
    map.putString("creator", team.getCreator());
    map.putString("announcement", team.getAnnouncement());
    map.putString("introduce", team.getIntroduce());
    map.putInt("memberCount", team.getMemberCount());
    map.putInt("memberLimit", team.getMemberLimit());
    map.putString("notify", team.getMessageNotifyType().toString());
    map.putString("verifyType", String.valueOf(team.getVerifyType()));
    map.putString("createTime", String.valueOf(team.getCreateTime()));

    return map;
  }
}
