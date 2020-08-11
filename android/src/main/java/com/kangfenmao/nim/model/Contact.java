package com.kangfenmao.nim.model;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;

public class Contact {
  String account;

  public Contact(String account) {
    this.account = account;
  }

  public WritableMap getContact() {
    NimUserInfo user = NIMClient.getService(UserService.class).getUserInfo(this.account);
    WritableMap contact = Arguments.createMap();

    contact.putString("account", user.getAccount());
    contact.putString("name", user.getName());
    contact.putString("avatar", user.getAvatar());
    contact.putString("signature", user.getSignature());
    contact.putString("mobile", user.getMobile());
    contact.putString("gender", user.getGenderEnum().toString());
    contact.putString("email", user.getEmail());
    contact.putString("birthday", user.getBirthday());

    return contact;
  }
}
