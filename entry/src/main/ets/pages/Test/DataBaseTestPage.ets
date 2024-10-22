import { privacyNoteDB } from '../../dababase/PrivacyNoteDB'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct DataBaseTestPage {
  build() {
    Column() {
      Button('插入数据')
        .onClick(async ()=>{
          const id=await privacyNoteDB.insert({
            id:null,    //自动递增
            title:"标题",
            content:"内容",
            date_added:Date.now()
          })
          promptAction.showToast({message:"新增数据成功 ID"+id})
        })
    }
    .height('100%')
    .width('100%')
  }
}