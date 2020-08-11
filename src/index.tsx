import { NativeModules, NativeEventEmitter } from 'react-native'

type PromiseResult = {
  code: string
  message: string
}

export type NimConversation = {
  id: string
  name: string
  avatar: string
  content: string
  type: string
  unreadCount: number
  time: string
}

export type NimContact = {
  account: string
  name: string
  avatar: string
  signature: string
  mobile: string
  gender: string
  email: string
  birthday: string
}

export type NimMessage = {
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

export type NimTeam = {
  id: string
  name: string
  icon: string
  type: string
  creator: string
  announcement: string
  introduce: string
  memberCount: number
  memberLimit: number
  verifyType: string
  createTime: string
  myTeam: boolean
}

export enum NimSessionTypeEnum {
  P2P = 'P2P',
  Team = 'Team',
}

export enum NimMessageStatusEnum {
  Draft = 'draft',
  Sending = 'sending',
  Success = 'success',
  fail = 'fail',
  read = 'read',
  unread = 'unread',
}

export type NIMLoginResult = PromiseResult

interface NeteaseImInterface {
  init(appKey: string, apnsCerts: string): void
  login(account: string, token: string): Promise<NIMLoginResult>
  autoLogin(): void
  getLogined(): Promise<boolean>
  getConnectStatus(): Promise<PromiseResult>
  logout(): void
  sendMessage(
    account: string,
    text: string,
    type: NimSessionTypeEnum,
    resend: boolean
  ): Promise<PromiseResult>
  getConversations(): Promise<NimConversation[]>
  deleteConversation(account: string, sessionType: NimSessionTypeEnum): void
  getContact(account: string): Promise<NimContact>
  getMessage(
    messageId: string,
    account: string,
    sessionType: NimSessionTypeEnum
  ): Promise<NimMessage>
  getTeam(teamId: string): Promise<NimTeam>
  getTeams(): Promise<NimTeam[]>
  sdkVersion: string
}

const NeteaseIm: NeteaseImInterface = NativeModules.NeteaseIm
const NeteaseImEvent = new NativeEventEmitter(NeteaseIm as any)

export { NeteaseIm, NeteaseImEvent }
