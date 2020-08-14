import React, { useEffect, useCallback } from 'react'
import { StyleSheet, View, Button, EmitterSubscription, Platform } from 'react-native'
import {
  NeteaseIm,
  NeteaseImEvent,
  NIM,
  SessionTypeEnum,
} from '@kangfenmao/react-native-netease-im'
import ENV from '../env.json'

export default function App() {
  const me = {
    account: Platform.OS === 'ios' ? 'kangfenmao' : 'excitedcat',
    token: '123456',
  }

  const toUser = {
    account: Platform.OS === 'ios' ? 'excitedcat' : 'kangfenmao',
    sessionType: SessionTypeEnum.P2P,
  }

  const toTeam = {
    account: '2872214734',
    sessionType: SessionTypeEnum.Team,
  }

  const init = useCallback(() => {
    NeteaseIm.init(ENV.appKey, ENV.apnsCername)
    autoLogin()
  }, [])

  useEffect(() => {
    const listeners: EmitterSubscription[] = []

    listeners.push(
      NeteaseImEvent.addListener('onConnectStatusChanged', (event: NIM.ConnectStatus) =>
        console.log(event)
      ),
      NeteaseImEvent.addListener('onMessages', (messages: NIM.Message[]) => console.log(messages)),
      NeteaseImEvent.addListener('onConversationsChanged', (conversations: NIM.Conversation[]) =>
        console.log(conversations)
      )
    )

    init()

    return () => listeners.forEach((listener) => listener.remove())
  }, [init])

  const login = async () => {
    try {
      const result = await NeteaseIm.login(me.account, me.token)
      console.log(result)
    } catch (error) {
      console.log({ code: error.code, message: error.message })
    }
  }

  const autoLogin = async () => {
    try {
      await NeteaseIm.autoLogin()
    } catch (error) {
      console.log({ code: error.code, message: error.message })
    }
  }

  const getLoggined = async () => {
    console.log(await NeteaseIm.getLogined())
  }

  const getConnectStatus = async () => {
    console.log(await NeteaseIm.getConnectStatus())
  }

  const logout = () => {
    NeteaseIm.logout()
  }

  const sendMessage = async (sessionType: SessionTypeEnum) => {
    const randomString = Math.random().toString(36).substr(2)
    const user = sessionType === SessionTypeEnum.P2P ? toUser : toTeam

    try {
      const result = await NeteaseIm.sendMessage(
        user.account,
        randomString,
        user.sessionType,
        false
      )
      console.log(result)
    } catch (error) {
      console.log({ code: error.code, message: error.message })
    }
  }

  const resetConversationUnreadCount = () => {
    NeteaseIm.resetConversationUnreadCount(toUser.account, SessionTypeEnum.P2P)
  }

  const getMessage = async () => {
    const message = await NeteaseIm.getMessage(
      '0296361cfdd64eabaa9f5dec12929d0e',
      toUser.account,
      SessionTypeEnum.P2P
    )

    console.log(message)
  }

  const getHistoryMessages = async () => {
    const messages = await NeteaseIm.getHistoryMessages(
      toUser.account,
      SessionTypeEnum.P2P,
      '',
      20,
      true
    )

    console.log(messages)
  }

  const getConversations = async () => {
    console.log(await NeteaseIm.getConversations())
  }

  const deleteConversation = () => {
    NeteaseIm.deleteConversation(toUser.account, toUser.sessionType)
  }

  const getTeams = async () => {
    console.log('teams:', await NeteaseIm.getTeams())
  }

  const getSdkVersion = () => {
    console.log('version:', NeteaseIm.sdkVersion)
  }

  return (
    <View style={styles.container}>
      <Button title="初始化" onPress={init} />
      <Button title="登录" onPress={login} />
      <Button title="自动登录" onPress={autoLogin} />
      <Button title="是否登录" onPress={getLoggined} />
      <Button title="连接状态" onPress={getConnectStatus} />
      <Button title="退出" onPress={logout} />
      <Button title="发消息(P2P)" onPress={() => sendMessage(SessionTypeEnum.P2P)} />
      <Button title="发消息(Team)" onPress={() => sendMessage(SessionTypeEnum.P2P)} />
      <Button title="获取一条消息" onPress={getMessage} />
      <Button title="历史消息" onPress={getHistoryMessages} />
      <Button title="最近会话" onPress={getConversations} />
      <Button title="删除一条会话" onPress={deleteConversation} />
      <Button title="重置会话未读数" onPress={() => resetConversationUnreadCount()} />
      <Button title="我的群" onPress={getTeams} />
      <Button title="SDK" onPress={getSdkVersion} />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
