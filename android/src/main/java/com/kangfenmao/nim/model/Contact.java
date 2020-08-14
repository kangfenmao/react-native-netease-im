package com.kangfenmao.nim.model;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;

public class Contact {
  String account;
  NimUserInfo user;

  public Contact(String account) {
    this.account = account;
  }

  public synchronized WritableMap getContact() throws InterruptedException {
    final CountDownLatch latch = new CountDownLatch(1);

    this.user = NIMClient.getService(UserService.class).getUserInfo(this.account);

    if (this.user == null) {
      List<String> accounts = new ArrayList<>();
      accounts.add(this.account);

      NIMClient.getService(UserService.class).fetchUserInfo(accounts).setCallback(new RequestCallbackWrapper<List<NimUserInfo>>() {
        @Override
        public void onResult(int code, List<NimUserInfo> result, Throwable exception) {
          if (exception == null && result != null) {
            user = result.get(0);
          }
          latch.countDown();
        }
      });
    }

    latch.await();

    if (this.user == null) {
      return null;
    }

    WritableMap contact = Arguments.createMap();

    contact.putString("account", this.user.getAccount());
    contact.putString("name", this.user.getName());
    contact.putString("avatar", this.user.getAvatar());
    contact.putString("signature", this.user.getSignature());
    contact.putString("mobile", this.user.getMobile());
    contact.putString("gender", this.user.getGenderEnum().toString());
    contact.putString("email", this.user.getEmail());
    contact.putString("birthday", this.user.getBirthday());

    return contact;
  }
}
