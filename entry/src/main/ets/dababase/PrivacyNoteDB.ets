import { relationalStore, ValuesBucket } from '@kit.ArkData';

//继承数据库相关的类
export interface PrivacyNoteDBInfo extends ValuesBucket{
  id:number|null,
  title:string,
  content:string,
  date_added:number
}

class PrivacyNoteDB{
  //数据库操作实列
  private store:relationalStore.RdbStore|null=null;

  //数据库表名
  private tableName="privacy_note"
  //sql 语句 创建表
  private sqlCreate=`CREATE TABLE IF NOT EXISTS ${this.tableName} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  date_added INTEGER NOT NULL
  )`

  //构造函数 得到数据实例后就创建表
  constructor() {
   this.getStoreInstance().then((store=>{
   store.executeSql(this.sqlCreate)
   }))
  }

  async getStoreInstance(){
  //如果已经打开过就不在重新打开
  if(this.store){
    return this.store
  }

  //创建/打开数据库
     this.store=await relationalStore.getRdbStore(getContext(),{
      name:"guardian.db",
      securityLevel:relationalStore.SecurityLevel.S1  //安全等级 （设备之间共享）
    })
    //返回 操作数据库实列
    return this.store;
  }

  //插入数据
  async insert(value:PrivacyNoteDBInfo){
   const store= await this.getStoreInstance();
   return store.insert(this.tableName,value)
  }

  //查询数据
  async query(id?:number){
    //创建/打开数据库
   const store=await this.getStoreInstance()
    //谓词(查询条件)
    const predicates=new relationalStore.RdbPredicates(this.tableName)
    if(id){
      predicates.equalTo('id',id)     //传了某一个ID 就只查一个
    }else{
      predicates.orderByDesc('id')
    }

    //查询 返回查询集合
    const resultSet=await store.query(predicates)
    const list:PrivacyNoteDBInfo[]=[]
    //指针(游标)移动到下一行
    while (resultSet.goToNextRow()){
      // const item:PrivacyNoteDBInfo={
      //   id:resultSet.getLong(0),
      //   title:resultSet.getString(1),
      //   content:resultSet.getString(2),
      //   date_added:resultSet.getLong(3)
      // }
      //api 11 新增getRow() 直接获取整行
      const item=resultSet.getRow() as PrivacyNoteDBInfo
      list.push(item)
    }
    //释放结果集 释放资源
    resultSet.close()
    return list;
  }

  //删除数据
  async delete(id:number){
   const store=await this.getStoreInstance();
   //谓词（条件）
   const predicates=new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id',id)
    return store.delete(predicates)
  }

  //更新数据
  async update(value:PrivacyNoteDBInfo){
  //id 为空就不执行
  if(!value.id){
    return Promise.reject()
  }
   const store=await this.getStoreInstance();

   const predicates=new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id',value.id)
    //更新
    return store.update(value,predicates)
  }

}

export const privacyNoteDB=new PrivacyNoteDB()