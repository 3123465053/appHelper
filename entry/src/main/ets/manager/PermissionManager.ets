import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';

class PermissionManager{

  //检查是否授权
  checkPermissions(permissions:Permissions[]){
    //创建应用程序管理器
   const atManager =abilityAccessCtrl.createAtManager();
   const bundleInfo =bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
   //获取tokenID 程序标识
   const tokenID=bundleInfo.appInfo.accessTokenId;
   //检查权限是否授权 （map 对数组中的每个元素执行一个指定的函数，并返回一个新的数组）
   const grantStatus=permissions.map(item=>atManager.checkAccessTokenSync(tokenID,item))
    //返回检测结果
   return grantStatus.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
  }

  //动态申请权限（首次弹窗申请）
  async requestPermissions(permissions:Permissions[]){

    //1.创建应用权限管理
    const atManager=abilityAccessCtrl.createAtManager();
    //2.权限申请
    const requestResult= await atManager.requestPermissionsFromUser(getContext(),permissions)

    //检查权限是否全部授权 （有一个不瞒足就返回false）
    const isAuth=requestResult.authResults.every(item=>item===abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    //Promise.reject() 返回一个Promise错误 让 await 后续代码不被执行 错误可被 catch捕获
    return isAuth===true ?Promise.resolve(true):Promise.reject(false)
  }

  //打开系统设置的权限管理页面（处理授权结果）
  openPermissionSettingsPage(){
    //获取上下文
    const context=getContext() as common.UIAbilityContext;
    //获取包信息
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    //打开设置页面
    context.startAbility({
      bundleName:"com.huawei.hmos.settings",  //固定写法：设置页的包名
     abilityName:"com.huawei.hmos.settings.MainAbility", //固定写法：设置页面的ability名
      uri:"application_info_entry",     //固定写法 打开 设置->应用和元服务
      parameters:{
        pushParams:bundleInfo.name   //应用包名
      }
    })
  }
}

//导出
export const permissionManger=new PermissionManager();