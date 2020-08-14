# react-native-netease-im

网易云信 React Native SDK

## 安装

```sh
npm install @kangfenmao/react-native-netease-im
```

## 使用方法

```js
import { NeteaseIm } from "@kangfenmao/react-native-netease-im"

NeteaseIm.foo()
```

详细使用方法参考 [App.tsx](example/src/App.tsx)

## 初始化

1. 在项目入口 index.js 中添加初始化方法

```js
import { NeteaseIm } from "@kangfenmao/react-native-netease-im"

NeteaseIm.init("appKey", "apnsCername")
```

注：第二个参数为iOS推送证书名，可为空字符串

2. Android 系统还需要在 MainApplication.java 的 `onCreate` 方法中添加初始化方法

```java
import com.kangfenmao.nim.NeteaseIm;

@Override
public void onCreate() {
  // ...
  NeteaseIm.init(this, "appKey");
}
```

## 事件

```js
const listeners: EmitterSubscription[] = []

listeners.push(
  // 连接状态改变
  NeteaseImEvent.addListener('onConnectStatusChanged', (event: ConnectStatus) =>
    console.log(event)
  ),
  // 收到消息
  NeteaseImEvent.addListener('onMessages', (messages: NIM.Message[]) =>
    console.log(messages)
  ),
  // 会话列表更新
  NeteaseImEvent.addListener('onConversationsChanged', (conversations: NIM.Conversation[]) =>
    console.log(conversations)
  )
)

// listeners.forEach((listener) => listener.remove())
```

## API

### login

备注：此方法用于用户第一次登录

```js
try {
  const result = await NeteaseIm.login('account', 'token')
  console.log(result)
} catch (error) {
  console.log(error.code, error.message)
}
```

### autoLogin

备注：
  1. 每次启动 App 后都需要调用此方法用于快速登录，快速登录不需要用户名和 token。
  2. 此方法没有返回值，需要监听连接状态。
  3. 当用户退出后必须重新登录后调用此接口才能成功登录。

```js
try {
  await NeteaseIm.autoLogin()
} catch (error) {
  console.log(error.message)
}
```

### getLoggined

检查登录状态

```js
const logined = await NeteaseIm.getLogined()
console.log('是否登录:', logined)
```

### logout

注意：这个方法没有返回值

```js
NeteaseIm.logout()
```

### sendMessage

发送文本消息

```js
try {
  const result = await NeteaseIm.sendMessage(
    'kangfenmao',
    '这是一条文本消息',
    NimSessionTypeEnum.P2P,
    false
  )
  console.log(result)
} catch (error) {
  console.log({ code: error.code, message: error.message })
}
```

```ts
sendMessage(
  account: string,
  text: string,
  type: NimSessionTypeEnum,
  resend: boolean
): Promise<NIM.PromiseResult>
```

### getMessage

获取一条消息

```js
getMessage(messageId: string, account: string, sessionType: SessionTypeEnum): Promise<NIM.Message>
```

### getHistoryMessages

获取历史消息

```js
getHistoryMessages(
  sessionId: string,
  sessionType: string,
  messageId: string,
  limit: number,
  asc: boolean
): Promise<NIM.Message[]>
```

messageId 为空字符串时查询最新的历史消息

### getConversations

获取最近会话列表

```js
await NeteaseIm.getConversations()
```

### deleteConversation

删除单条会话

```js
NeteaseIm.deleteConversation(sessionId, SessionType.P2P)
```

重置会话未读数

```js
NeteaseIm.resetConversationUnreadCount(sessionId, SessionTypeEnum.P2P)
```

### SDK version

```js
NeteaseIm.sdkVersion
```


## 推送配置

### iOS 推送配置

修改 `index.js` 中的初始化方法，第二个参数传入证书名：

```js
NeteaseIm.init("appKey", "apnsCertname")
```

### Android 推送配置

在 `MainApplication.java` 头部引入

```java
import com.netease.nimlib.sdk.mixpush.MixPushConfig;
```

修改 `onCreate` 方法中的初始化方法，加入 `MixPushConfig`:

```java
NeteaseIm.init(this, "appKey", mixPushConfig);
```

mixPushConfig 配置

```java
MixPushConfig mixPushConfig = new MixPushConfig();

// 小米推送
mixPushConfig.xmAppId = "";
mixPushConfig.xmAppKey = "";
mixPushConfig.xmCertificateName = "";

// 华为
mixPushConfig.hwAppId = "";
mixPushConfig.hwCertificateName = "";

// 魅族
mixPushConfig.mzAppId = "";
mixPushConfig.mzAppKey = "";
mixPushConfig.mzCertificateName = "";

// OPPO
mixPushConfig.oppoAppId = "";
mixPushConfig.oppoAppKey = "";
mixPushConfig.oppoAppSercet = "";
mixPushConfig.oppoCertificateName = "";

// VIVO
mixPushConfig.vivoCertificateName = "";
```

## Example

将项目 clone 到本地

运行

```
yarn prepair
```
修改 example/env.json

```
yarn example ios
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
