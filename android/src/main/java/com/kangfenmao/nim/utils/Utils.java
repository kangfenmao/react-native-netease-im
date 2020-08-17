package com.kangfenmao.nim.utils;

import android.content.Context;
import android.text.TextUtils;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.kangfenmao.nim.model.Contact;
import com.kangfenmao.nim.model.Team;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.RecentContact;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Utils {
  /**
   * 从本地读取上次登录成功时保存的用户登录信息
   *
   * @return LoginInfo
   */
  static public LoginInfo loginInfo(Context reactContext) {
    SharedPreferenceHelper SP_Helper = SharedPreferenceHelper.getInstance(reactContext);
    String account = SP_Helper.getString(SharedPreferenceHelper.Key.ACCOUNT);
    String token = SP_Helper.getString(SharedPreferenceHelper.Key.TOKEN);

    if (!TextUtils.isEmpty(account) && !TextUtils.isEmpty(token)) {
      return new LoginInfo(account, token);
    } else {
      return null;
    }
  }

  /**
   * 判断是否登录
   *
   * @return boolean
   */
  static public boolean isLogined() {
    StatusCode status = NIMClient.getStatus();
    return status == StatusCode.LOGINED;
  }

  /**
   * 获取连接状态
   *
   * @param status
   * @return
   */
  static public Map<String, String> getStatusMap(StatusCode status) {
    Map<String, String> result = new HashMap<String, String>();

    switch (status) {
      case UNLOGIN:
        result.put("code", "UNLOGIN");
        result.put("message", "未登录/登录失败");
        break;
      case NET_BROKEN:
        result.put("code", "NET_BROKEN");
        result.put("message", "网络连接已断开");
        break;
      case CONNECTING:
        result.put("code", "CONNECTING");
        result.put("message", "正在连接服务器");
        break;
      case LOGINING:
        result.put("code", "LOGINING");
        result.put("message", "正在登录中");
        break;
      case SYNCING:
        result.put("code", "SYNCING");
        result.put("message", "正在同步数据");
        break;
      case LOGINED:
        result.put("code", "LOGINED");
        result.put("message", "登录成功");
        break;
      case KICKOUT:
        result.put("code", "KICKOUT");
        result.put("message", "被其他端的登录踢掉");
        break;
      case KICK_BY_OTHER_CLIENT:
        result.put("code", "KICK_BY_OTHER_CLIENT");
        result.put("message", "被同时在线的其他端主动踢掉");
        break;
      case FORBIDDEN:
        result.put("code", "FORBIDDEN");
        result.put("message", "被服务器禁止登录");
        break;
      case VER_ERROR:
        result.put("code", "VER_ERROR");
        result.put("message", "客户端版本错误");
        break;
      case PWD_ERROR:
        result.put("code", "PWD_ERROR");
        result.put("message", "用户名或密码错误");
        break;
      default:
        result.put("code", "INVALID");
        result.put("message", "未定义");
        break;
    }

    return result;
  }

  /**
   * 从最近联系人中获取会话列表
   *
   * @param recentContacts
   * @return
   */
  static public WritableArray getConversationsFromRecentContacts(List<RecentContact> recentContacts) throws InterruptedException {
    WritableArray conversations = Arguments.createArray();

    for (int i = 0; i < recentContacts.size(); i++) {
      RecentContact recentContact = recentContacts.get(i);
      SessionTypeEnum sessionType = recentContact.getSessionType();

      // 获取最近联系人的ID（好友帐号，群ID等）
      String id = recentContact.getContactId();

      WritableMap conversation = Arguments.createMap();
      conversation.putString("id", recentContact.getContactId());
      conversation.putString("content", recentContact.getContent());
      conversation.putString("type", sessionType.toString());
      conversation.putInt("unread_count", recentContact.getUnreadCount());
      conversation.putString("time", String.valueOf(recentContact.getTime()));

      // P2P
      if (sessionType == SessionTypeEnum.P2P) {
        WritableMap contact = new Contact(id).getContact();

        if (contact == null) {
          return Arguments.createArray();
        }

        conversation.putString("name", contact.getString("name"));
        conversation.putString("avatar", contact.getString("avatar"));
      }

      // Team
      if (sessionType == SessionTypeEnum.Team) {
        WritableMap team = new Team(id).getTeam();
        conversation.putString("name", team.getString("name"));
        conversation.putString("avatar", team.getString("avatar"));
        conversation.putString("notify_type", team.getString("notify_type"));
        conversation.putString("verify_type", team.getString("verify_type"));
      }

      conversations.pushMap(conversation);
    }

    return conversations;
  }
}
