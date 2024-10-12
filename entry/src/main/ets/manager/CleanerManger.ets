import { permissionManger } from './PermissionManager'
import { Permissions } from '@kit.AbilityKit'
import promptAction from '@ohos.promptAction'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import dataSharePredicates from '@ohos.data.dataSharePredicates'
import { it } from '@ohos/hypium'

class CleanerManger{
  private permissions:Permissions[]=['ohos.permission.READ_IMAGEVIDEO',"ohos.permission.WRITE_IMAGEVIDEO"]
  private photoAssets:photoAccessHelper.PhotoAsset[]=[];

  //图片字段
  private fetchColumns:photoAccessHelper.PhotoKeys[]=[
    photoAccessHelper.PhotoKeys.DATE_ADDED,
    photoAccessHelper.PhotoKeys.SIZE
  ]


  //图片权限
  async requestPermissions(){
    try {
      await permissionManger.requestPermissions(this.permissions)
    } catch (e) {
      //未开启权限弹窗提示
      const res= await promptAction.showDialog({
        alignment:DialogAlignment.Center,
        title:"温馨提示",
        message:"手机瘦身功能需要获取权限，请在系统设置中打开相册权限",
        buttons:[
          {text:'取消',color:$r('app.color.font_sub')},
          {text:"立即开启",color:$r('app.color.brand')}
        ]
      })
    }
  }

  //获取图片/视频
  async getAssets(){
    //先申请权限
    await this.requestPermissions();
    //1.建立检索条件 用于获取图片资源
    const phAccessHelper=photoAccessHelper.getPhotoAccessHelper(getContext());
    const predicates=new dataSharePredicates.DataSharePredicates();

    //2.调用接口获取资源
    const fetchResult=await phAccessHelper.getAssets({
      fetchColumns:this.fetchColumns,
      predicates:predicates
    })

    //3.获取所有图片资源
    const photoAssets=await fetchResult.getAllObjects();
    //返回数据
    return photoAssets;
  }

  //获取屏幕截图列表
  async getScreenshotList(){
    const list=  await this.getAssets()
    //选出问价名包含“screenshot” 的就是截图
    return list.filter(item=>item.displayName.includes("screenshot"))
  }

  //获取视频列表
  async getVideo(){
    const list= await this.getAssets();
    return list.filter(item=>item.photoType===photoAccessHelper.PhotoType.VIDEO)
  }

  //删除图片
  async deletePhotos(uris:string[]){

  }
}

//导出
export const cleanerManger=new CleanerManger()