import { permissionManger } from '../../manager/PermissionManager';

@Entry
@Component
struct PermissionTestPage {
  @State message: string = 'Hello World';

  build() {
    Column({space:15}){
      Button("打开设置页面")
        .onClick(()=>{
          permissionManger.openPermissionSettingsPage()
        })
      Button("权限申请")
        .onClick(()=>{
          permissionManger.requestPermissions(['ohos.permission.READ_CONTACTS'])
        })
      Button("权限检测")
        .onClick(()=>{
          let res=  permissionManger.checkPermissions(['ohos.permission.READ_CONTACTS'])
          AlertDialog.show({message:JSON.stringify(res)})
        })
    }.width('100%')
  }
}