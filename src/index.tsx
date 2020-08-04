import { NativeModules } from 'react-native';

type NeteaseImType = {
  multiply(a: number, b: number): Promise<number>;
};

const { NeteaseIm } = NativeModules;

export default NeteaseIm as NeteaseImType;
