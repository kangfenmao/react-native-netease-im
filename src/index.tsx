import { NativeModules, NativeEventEmitter } from 'react-native'

interface NeteaseImInterface {
  init(appKey: string, apnsCerts: string): void
  login(account: string, token: string): Promise<NIM.PromiseResult>
  autoLogin(): void
  getLogined(): Promise<boolean>
  getConnectStatus(): Promise<NIM.PromiseResult>
  logout(): void
  sendMessage(
    account: string,
    text: string,
    type: NIM.ENUM.SessionType,
    resend: boolean
  ): Promise<NIM.PromiseResult>
  getConversations(): Promise<NIM.Conversation[]>
  deleteConversation(account: string, sessionType: NIM.ENUM.SessionType): void
  getContact(account: string): Promise<NIM.Contact>
  getMessage(
    messageId: string,
    account: string,
    sessionType: NIM.ENUM.SessionType
  ): Promise<NIM.Message>
  getTeam(teamId: string): Promise<NIM.Team>
  getTeams(): Promise<NIM.Team[]>
  sdkVersion: string
}

export namespace NIM {
  export type PromiseResult = {
    code: string
    message: string
  }
  export type ConnectStatus = {
    message: string
    code: NIM.ENUM.ConnectStatusCode
  }
  export type Conversation = {
    id: string
    name: string
    avatar: string
    content: string
    type: string
    unreadCount: number
    time: string
  }
  export type Contact = {
    account: string
    name: string
    avatar: string
    signature: string
    mobile: string
    gender: string
    email: string
    birthday: string
  }
  export type Message = {
    id: string
    session_id: string
    session_type: string
    account: string
    nickname: string
    content: string
    extension: string
    time: string
    type: string
    direct: string
  }
  export type Team = {
    id: string
    name: string
    icon: string
    type: string
    creator: string
    announcement: string
    introduce: string
    memberCount: number
    memberLimit: number
    notifyType: NIM.ENUM.TeamNotifyType
    verifyType: NIM.ENUM.TeamVerifyType
    createTime: string
  }
  export namespace ENUM {
    export enum SessionType {
      P2P = 'P2P',
      Team = 'Team',
    }
    export enum MessageStatus {
      Draft = 'draft',
      Sending = 'sending',
      Success = 'success',
      fail = 'fail',
      read = 'read',
      unread = 'unread',
    }
    export enum ConnectStatusCode {
      CONNECTING, // 正在连接服务器
      CONNECTED, // 连接服务器成功
      CONNECT_FAILED, // 连接服务器失败
      LOGINING, // 登录中
      LOGINED, // 登录成功
      UNLOGIN, // 未登录/登录失败
      SYNCING, // 开始同步数据
      SYNCED, // 同步数据完成
      NET_BROKEN, // 网络连接已断开
      NET_CHANGED, // 网络切换
      KICKOUT, // 被其他端的登录踢掉
      KICK_BY_OTHER_CLIENT, // 被同时在线的其他端主动踢掉
      FORBIDDEN, // 被服务器禁止登录
      VER_ERROR, // 客户端版本错误
      PWD_ERROR, // 用户名或密码错误
      INVALID, // 未定义
    }
    export enum TeamNotifyType {
      All = 'All',
      Manager = 'Manager',
      Mute = 'Mute',
    }
    export enum TeamVerifyType {
      Free = 'Free', // 可以自由加入，无需管理员验证
      Apply = 'Manager', // 需要先申请，管理员统一方可加入
      Private = 'Mute', // 私有群，不接受申请，仅能通过邀请方式入群
    }
  }
}

const NeteaseIm: NeteaseImInterface = NativeModules.NeteaseIm
const NeteaseImEvent = new NativeEventEmitter(NeteaseIm as any)

export { NeteaseIm, NeteaseImEvent }
