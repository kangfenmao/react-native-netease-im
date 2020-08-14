package com.kangfenmao.nim;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.kangfenmao.nim.model.Contact;
import com.kangfenmao.nim.model.Message;
import com.kangfenmao.nim.model.Team;
import com.kangfenmao.nim.utils.SharedPreferenceHelper;
import com.kangfenmao.nim.utils.Utils;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthService;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.msg.MessageBuilder;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.IMMessage;
import com.netease.nimlib.sdk.msg.model.QueryDirectionEnum;
import com.netease.nimlib.sdk.msg.model.RecentContact;
import com.netease.nimlib.sdk.team.TeamService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NeteaseImModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private final SharedPreferenceHelper sharedPreference;

  public NeteaseImModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.sharedPreference = SharedPreferenceHelper.getInstance(reactContext);
  }

  @Override
  public String getName() {
    return "NeteaseIm";
  }

  /**
   * 获取常量
   *
   * @return
   */
  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    constants.put("sdkVersion", NIMClient.getSDKVersion());
    return constants;
  }

  /**
   * 初始化
   *
   * @param appKey
   * @param apnsCerts iOS push 证书名
   */
  @ReactMethod
  public void init(String appKey, String apnsCerts) {
    NeteaseImObserver observer = new NeteaseImObserver(this.reactContext);
    observer.addConnectStatusObserver();
    observer.addIncomingMessagesObserver();
    observer.addRecentContactObserver();
  }

  /**
   * 登录
   *
   * @param account
   * @param token
   * @param promise
   */
  @ReactMethod
  public void login(String account, String token, Promise promise) {
    LoginInfo info = new LoginInfo(account, token);
    SharedPreferenceHelper sharedPreference = this.sharedPreference;

    WritableMap result = Arguments.createMap();
    result.putString("message", "登录成功");
    result.putString("code", "LOGINED");

    if (Utils.isLogined()) {
      promise.resolve(result);
      return;
    }

    RequestCallback<LoginInfo> callback =
      new RequestCallback<LoginInfo>() {
        @Override
        public void onSuccess(LoginInfo param) {
          sharedPreference.put(SharedPreferenceHelper.Key.ACCOUNT, account);
          sharedPreference.put(SharedPreferenceHelper.Key.TOKEN, token);
          promise.resolve(result);
        }

        @Override
        public void onFailed(int code) {
          // 账号密码错误
          if (code == 302) {
            promise.reject(String.valueOf(code), "账号或密码错误");
          } else {
            promise.reject(String.valueOf(code), "登录失败");
          }
        }

        @Override
        public void onException(Throwable exception) {
          promise.reject("-1", "程序错误");
        }
      };

    // 执行手动登录
    NIMClient.getService(AuthService.class).login(info).setCallback(callback);
  }

  /**
   * 自动登录
   */
  @ReactMethod
  public void autoLogin(Promise promise) {
    if (Utils.isLogined()) {
      promise.resolve(true);
      return;
    }

    LoginInfo loginInfo = Utils.loginInfo(this.reactContext);

    if (loginInfo instanceof LoginInfo) {
      NIMClient.getService(AuthService.class).login(loginInfo);
      promise.resolve(true);
    } else {
      promise.reject("failed", "用户已退出登录");
    }
  }

  /**
   * 是否登录
   *
   * @param promise
   */
  @ReactMethod
  public void getLogined(Promise promise) {
    StatusCode status = NIMClient.getStatus();
    promise.resolve(status == StatusCode.LOGINED);
  }

  /**
   * 连接状态
   *
   * @param promise
   */
  @ReactMethod
  public void getConnectStatus(Promise promise) {
    StatusCode status = NIMClient.getStatus();
    Map connectStatus = Utils.getStatusMap(status);

    WritableMap params = Arguments.createMap();
    params.putString("code", connectStatus.get("code").toString());
    params.putString("message", connectStatus.get("message").toString());

    promise.resolve(params);
  }

  /**
   * 退出登录
   */
  @ReactMethod
  public void logout() {
    NIMClient.getService(AuthService.class).logout();
    this.sharedPreference.clear();
  }

  /**
   * 发送消息
   */
  @ReactMethod
  public void sendMessage(String account, String text, String type, Boolean resend, Promise promise) {
    SessionTypeEnum sessionType = SessionTypeEnum.P2P;

    switch (type) {
      case "P2P":
        sessionType = SessionTypeEnum.P2P;
        break;
      case "Team":
        sessionType = SessionTypeEnum.Team;
        break;
    }

    // 创建一个文本消息
    IMMessage textMessage = MessageBuilder.createTextMessage(account, sessionType, text);

    // 发送给对方
    NIMClient.getService(MsgService.class).sendMessage(textMessage, resend).setCallback(new RequestCallback<Void>() {
      @Override
      public void onSuccess(Void param) {
        WritableMap result = Arguments.createMap();
        result.putInt("code", 200);
        result.putString("message", "发送成功");
        promise.resolve(result);
      }

      @Override
      public void onFailed(int code) {
        promise.reject(String.valueOf(code), "发送失败");
      }

      @Override
      public void onException(Throwable exception) {
        promise.reject("-1", exception.getMessage(), exception);
      }
    });
  }

  /**
   * 最近会话
   */
  @ReactMethod
  public void getConversations(Promise promise) {
    NIMClient.getService(MsgService.class).queryRecentContacts()
      .setCallback(new RequestCallbackWrapper<List<RecentContact>>() {
        @Override
        public void onResult(int code, List<RecentContact> messages, Throwable e) {
          promise.resolve(Utils.getConversationsFromRecentContacts(messages));
        }
      });
  }

  /**
   * 删除单条会话
   */
  @ReactMethod
  public void deleteConversation(String sessionId, String sessionType) {
    NIMClient.getService(MsgService.class).deleteRecentContact2(sessionId, SessionTypeEnum.valueOf(sessionType));
  }

  /**
   * 重置会话未读数
   * @param sessionId
   * @param sessionType
   */
  @ReactMethod
  public void resetConversationUnreadCount(String sessionId, String sessionType) {
    NIMClient.getService(MsgService.class).clearUnreadCount(sessionId, SessionTypeEnum.valueOf(sessionType));
  }

  /**
   * 获取总未读数
   * @param promise
   */
  @ReactMethod
  public void getTotalUnreadCount(Promise promise) {
    try {
      int unreadNum = NIMClient.getService(MsgService.class).getTotalUnreadCount();
      promise.resolve(unreadNum);
    } catch (Exception e) {
      promise.resolve(0);
    }
  }

  /**
   * 获取联系人信息
   */
  @ReactMethod
  public void getContact(String account, Promise promise) {
    Contact contact = new Contact(account);
    promise.resolve(contact.getContact());
  }

  /**
   * 获取群信息
   */
  @ReactMethod
  public void getTeam(String teamId, Promise promise) {
    Team team = new Team(teamId);
    promise.resolve(team.getTeam());
  }

  /**
   * 获取我的群组
   */
  @ReactMethod
  public void getTeams(Promise promise) {
    List<com.netease.nimlib.sdk.team.model.Team> teams = NIMClient.getService(TeamService.class).queryTeamListBlock();
    WritableArray array = Arguments.createArray();

    for (int i = 0; i < teams.size(); i++) {
      Team team = new Team(teams.get(i));
      array.pushMap(team.getTeam());
    }

    promise.resolve(array);
  }

  /**
   * 获取单个消息
   */
  @ReactMethod
  public void getMessage(String messageId, String account, String sessionType, Promise promise) {
    Message message = new Message(messageId);
    promise.resolve(message.getMessage());
  }

  /**
   * 获取历史消息
   */
  @ReactMethod
  public void getHistoryMessages(String sessionId, String sessionType, String messageId, int limit, boolean asc, Promise promise) {
    WritableArray messages = Arguments.createArray();
    IMMessage anchor = null;

    if (messageId.length() == 0) {
      try {
        IMMessage lastMessage = NIMClient.getService(MsgService.class).queryLastMessage(sessionId, SessionTypeEnum.valueOf(sessionType));
        anchor = lastMessage;
      } catch (IllegalStateException e) {
        // anchor = null;
      }
    } else {
      anchor = new Message(messageId).getImMessage();
    }

    if (anchor == null) {
      promise.resolve(messages);
      return;
    }

    List<IMMessage> imMessages = NIMClient.getService(MsgService.class).queryMessageListExBlock(
      anchor,
      QueryDirectionEnum.QUERY_OLD,
      limit,
      asc
    );

    for (int i = 0; i < imMessages.size(); i++) {
      IMMessage imMessage = imMessages.get(i);
      Message message = new Message(imMessage.getUuid());
      messages.pushMap(message.getMessage());
    }

    promise.resolve(messages);
  }
}
