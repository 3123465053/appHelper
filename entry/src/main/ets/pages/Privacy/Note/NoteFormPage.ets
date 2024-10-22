// 页面参数
import { privacyNoteDB } from '../../../dababase/PrivacyNoteDB'
import { promptAction, router } from '@kit.ArkUI'

interface RouterParams {
  id?: number
}

@Entry
@Component
struct NoteDetailPage {
  // 标题
  @State title: string = ''
  // 内容
  @State content: string = ''
  // 页面参数
  @State routerParams: RouterParams = {}

  aboutToAppear(): void {
   const params=router.getParams() as RouterParams
    if(params){
      this.routerParams=params
      this.getDetail()
    }
  }

  //获取详情
  async getDetail(){
    const list=await privacyNoteDB.query(this.routerParams.id)
    const detail=list[0]
    if(detail){
      this.title=detail.title;
      this.content=detail.content
    }
  }

  //保存
  async onSubmit(){
    if(this.routerParams.id){
      await privacyNoteDB.update({
        id:this.routerParams.id,
        title:this.title,
        content:this.content,
        date_added:Date.now()
      })
    }else {
      const id=await privacyNoteDB.insert({
        id:null,
        title:this.title,
        content:this.content,
        date_added:Date.now()
      })
    }
    promptAction.showToast({message:"保存成功"})
    router.back()
  }

  //用户返回时触发（生命周期函数）
  onBackPress(): boolean | void {
    //编辑笔记时不阻止回传
    if(this.routerParams.id){
      return false
    }

   promptAction.showDialog({
     title:"温馨提示",
     message:"输入的内容还没有保存，是否放弃?",
     buttons:[
       {text:"取消",color:$r('app.color.font_sub')},
       {text:"确定",color:$r('app.color.brand')}
     ]
   }).then((res)=>{
     if(res.index===1){
       router.back()
     }
   })

    //阻断默认返回的行为
    return true;
  }


  @Builder
  NavigationMenus() {
    Row() {
      Text('保存')
        .fontSize(16)
        .fontColor(this.title.trim() !== '' ? $r('app.color.font') : $r('app.color.font_sub'))
        .enabled(this.title.trim() !== '')
        .onClick(() => {
          // TODO：保存(新增/修改)
          this.onSubmit()
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 10 }) {
          Text('标题')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextInput({ placeholder: '请输入笔记标题', text: this.title })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .padding({ left: 10 })
            .onChange((text) => {
              this.title = text
            })
            .onSubmit(() => {
              // TODO：提交表单(新增/修改)
            })
          Text('内容')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextArea({ placeholder: '请输入笔记内容', text: this.content })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .layoutWeight(1)
            .padding(10)
            .onChange((text) => {
              this.content = text
            })
        }
        .padding({ bottom: 160 })

        if (this.routerParams.id) {
          // 底部按钮
          Row({ space: 10 }) {
            Button('删除')
              .type(ButtonType.Normal)
              .backgroundColor('#FF5E5D')
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                // TODO：删除
              })
            Button('分享')
              .type(ButtonType.Normal)
              .backgroundColor($r('app.color.brand'))
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                // TODO：分享
              })
          }
          .padding({ bottom: 80 })
        }
      }
      .padding({ left: 15, right: 15, top: 20 })

    }
    .title('笔记')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .menus(this.NavigationMenus())

  }
}