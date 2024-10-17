import CryptoJS from '@ohos/crypto-js'

export  function encryptMD5(str:string){
  //md5加密
  return CryptoJS.MD5(str).toString()
}