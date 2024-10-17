import userAuth from '@ohos.userIAM.userAuth'
import { reject } from '@wolfx/lodash'

class UserAuthManager{
  //认证等级 越高面容指纹 检测越严格
  authTrustLevel:userAuth.AuthTrustLevel=userAuth.AuthTrustLevel.ATL3

  //认证类型列表
  authTypes:userAuth.UserAuthType[]=[
    userAuth.UserAuthType.PIN,
    userAuth.UserAuthType.FACE,
    userAuth.UserAuthType.FINGERPRINT
  ]

  //认证参数
  private authParam:userAuth.AuthParam={
    challenge:new Uint8Array([50,50,50,1,164,458]) , //挑战值 用来防止攻击
    authType:this.authTypes,
    authTrustLevel:this.authTrustLevel
  }

  //配置认证界面
  private  widgetParam:userAuth.WidgetParam={
    title:"请进行省份认证"
  }


  //查询认证能力是否支持 有一项支持即可
  checkUserAuthSupport(){
    const res=this.authTypes.map((item)=>{
      try {
        //支持不会异常 不支持会有异常
        userAuth.getAvailableStatus(item,this.authTrustLevel)
        return true
      } catch  {
        return false
      }
    })
    //some 有一项满足即可
    return res.some(v=>v===true)
  }

  //发起原生用户认证
  startUserAuth():Promise<boolean>{
    return new Promise((resolve,reject)=>{
      //1. 获取认证实列对象
     const userAuthInstance=userAuth.getUserAuthInstance(this.authParam,this.widgetParam)

      //2 订阅认证结果
      userAuthInstance.on("result",{
        onResult(result){
          if(result.result===userAuth.UserAuthResultCode.SUCCESS){
            resolve(true)
          } else {
            reject(false)
          }

          //认证结束 主动关闭订阅 释放资源
          userAuthInstance.off('result')
        }
      })

      //3.开始认证
      userAuthInstance.start()
    })
  }
}

export const userAuthManager=new UserAuthManager()