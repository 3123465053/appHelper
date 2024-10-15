import { permissionManger } from './PermissionManager'
import { Permissions } from '@kit.AbilityKit'
import promptAction from '@ohos.promptAction'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import dataSharePredicates from '@ohos.data.dataSharePredicates'
import { it } from '@ohos/hypium'
import { KILO_BYTE } from '../common/utils/formatByte'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'

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

  //获取大尺寸图片 用于压缩
  async getLargeSizeList(){
    const photoAssets=await this.getAssets();
    //过滤出大于 200kb的图片
    const largeSize=200*KILO_BYTE;
    return photoAssets.filter(item=>item.get(photoAccessHelper.PhotoKeys.SIZE) as number >largeSize)
  }

  //删除图片
  async deletePhotos(uris:string[]){
    //获取所有图片/视频
  const photoAssets =await this.getAssets();
  //获取选择图片assets对象
  const list=photoAssets.filter(item=>uris.includes(item.uri))
    return photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(),list)
  }

  //压缩图片
  async compressImage(uri:string){
    //创建图片打包器
    const imagePicker=image.createImagePacker()
    //准备图片资源
    const file=fileIo.openSync(uri)
    //createImageSource 不能直接使用uri 需要给予uri打开文件 再传入文件的fd
    const imageSource=image.createImageSource(file.fd)
    // 图片压缩(文件流)  format 格式 quality质量
    const arrBuffer= await imagePicker.packing(imageSource,{format:"image/jpeg",quality:80})

    //把压缩后的图片写入图库
    const phAccessHelper=photoAccessHelper.getPhotoAccessHelper(getContext())
    const createAssetUri=await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE,'jpg')
    //打开文件 并设置可读可写
    const createAssetFile=fileIo.openSync(createAssetUri,fileIo.OpenMode.READ_WRITE)
    //写入数据
    fileIo.writeSync(createAssetFile.fd,arrBuffer)
    fileIo.close(createAssetFile.fd)
  }
}

//导出
export const cleanerManger=new CleanerManger()