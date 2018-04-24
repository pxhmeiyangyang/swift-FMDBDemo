
//
//  FMDBManager.swift
//  FMDBTest
//
//  Created by pxh on 2018/4/23.
//  Copyright © 2018年 pxh. All rights reserved.
//

import UIKit



class FMDBManager: NSObject {
    
    class func getDatabase()->FMDatabase{
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).last!
        return FMDatabase.init(url: URL.init(string: path + "/test.sqlite")!)
    }
    
    //MARK: - 创建表格
    
    /// 创建表格
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - arFields: 表字段
    ///   - arFieldsType: 表属性
    class func createTable(tableName:String , arFields:NSArray, arFieldsType:NSArray){
        let db = getDatabase()
        if isTableExist(tableName: tableName) { //if table is exist return
            return
        }
        if db.open() {
            var  sql = "CREATE TABLE IF NOT EXISTS " + tableName + "(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
            let arFieldsKey:[String] = arFields as! [String]
            let arFieldsType:[String] = arFieldsType as! [String]
            for i in 0..<arFieldsType.count {
                if i != arFieldsType.count - 1 {
                    sql = sql + arFieldsKey[i] + " " + arFieldsType[i] + ", "
                }else{
                    sql = sql + arFieldsKey[i] + " " + arFieldsType[i] + ")"
                }
            }
            do{
                try db.executeUpdate(sql, values: nil)
                print("数据库操作====" + tableName + "表创建成功！")
            }catch{
                print(db.lastErrorMessage())
            }
            
        }
        db.close()
        
    }
    
    
    //MARK: - 添加数据
    /// 插入数据
    ///
    /// - Parameters:
    ///   - tableName: 表名字
    ///   - dicFields: key为表字段，value为对应的字段值
    class func insertDataToTable(tableName:String,dicFields:NSDictionary){
        let db = getDatabase()
        if db.open() {
            let arFieldsKeys:[String] = dicFields.allKeys as! [String]
            let arFieldsValues:[Any] = dicFields.allValues
            var sqlUpdatefirst = "INSERT INTO '" + tableName + "' ("
            var sqlUpdateLast = " VALUES("
            for i in 0..<arFieldsKeys.count {
                if i != arFieldsKeys.count-1 {
                    sqlUpdatefirst = sqlUpdatefirst + arFieldsKeys[i] + ","
                    sqlUpdateLast = sqlUpdateLast + "?,"
                }else{
                    sqlUpdatefirst = sqlUpdatefirst + arFieldsKeys[i] + ")"
                    sqlUpdateLast = sqlUpdateLast + "?)"
                }
            }
            do{
                try db.executeUpdate(sqlUpdatefirst + sqlUpdateLast, values: arFieldsValues)
                print("数据库操作==== 添加数据成功！")
            }catch{
                print(db.lastErrorMessage())
            }
            
        }
    }
    
    //MARK: - 修改数据
    /// 修改数据
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - dicFields: key为表字段，value为要修改的值
    ///   - ConditionsKey: 过滤筛选的字段
    ///   - ConditionsValue: 过滤筛选字段对应的值
    /// - Returns: 操作结果 true为成功，false为失败
    class func modifyToData(tableName:String , dicFields:NSDictionary ,ConditionsKey:String ,ConditionsValue :Int)->(Bool){
        var result:Bool = false
        let arFieldsKey : [String] = dicFields.allKeys as! [String]
        var arFieldsValues:[Any] = dicFields.allValues
        arFieldsValues.append(ConditionsValue)
        var sqlUpdate  = "UPDATE " + tableName +  " SET "
        for i in 0..<dicFields.count {
            if i != arFieldsKey.count - 1 {
                sqlUpdate = sqlUpdate + arFieldsKey[i] + " = ?,"
            }else {
                sqlUpdate = sqlUpdate + arFieldsKey[i] + " = ?"
            }
            
        }
        sqlUpdate = sqlUpdate + " WHERE " + ConditionsKey + " = ?"
        let db = getDatabase()
        if db.open() {
            do{
                try db.executeUpdate(sqlUpdate, values: arFieldsValues)
                print("数据库操作==== 修改数据成功！")
                result = true
            }catch{
                print(db.lastErrorMessage())
            }
        }
        return result
    }
    
    //MARK: - 查询数据
    /// 查询数据
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - arFieldsKey: 要查询获取的表字段
    /// - Returns: 返回相应数据
    class func selectFromTable(tableName:String,arFieldsKey:NSArray)->([NSMutableDictionary]){
        let dicFieldsValue :NSMutableDictionary = [:]
        var arFieldsValue = [NSMutableDictionary]()
        let sql = "SELECT * FROM " + tableName
        let db = getDatabase()
        if db.open() {
            do{
                let rs = try db.executeQuery(sql, values: nil)
                while rs.next() {
                    for i in 0..<arFieldsKey.count {
                        dicFieldsValue.setObject(rs.string(forColumn: arFieldsKey[i] as! String), forKey: arFieldsKey[i] as! NSCopying)
                    }
                    arFieldsValue.append(dicFieldsValue)
                }
            }catch{
                print(db.lastErrorMessage())
            }
            
        }
        return arFieldsValue
    }
    
    
    //MARK: - 删除数据
    /// 删除数据
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - FieldKey: 过滤的表字段
    ///   - FieldValue: 过滤表字段对应的值
    class func deleteFromTable(tableName:String,FieldKey:String,FieldValue:Any) {
        let db = getDatabase()
        if db.open() {
            let  sql = "DELETE FROM '" + tableName + "' WHERE " + FieldKey + " = ?"
            
            do{
                try db.executeUpdate(sql, values: [FieldValue])
                print("删除成功")
            }catch{
                print(db.lastErrorMessage())
            }
        }
        
    }
    
    //删除表格：
    class func dropTable(tableName:String) {
        let db = getDatabase()
        if db.open() {
            let  sql = "DROP TABLE " + tableName
            do{
                try db.executeUpdate(sql, values: nil)
                print("删除表格成功")
            }catch{
                print(db.lastErrorMessage())
            }
        }
        
    }
    
    
    /// 新增加表字段
    ///   原理：
    ///     修改表名，新建表，将数据从新插入
    /// - Parameters:
    ///   - tableName:表名称
    ///   - newField: 新增表字段
    ///   - dicFieldsAndType: 新表的全部字段 和字段对应的属性
    class func changTable(tableName:String,newField:String, arFields:NSArray, arFieldsType:NSArray){
        let db = getDatabase()
        if db.open() {
            if !db.columnExists(newField, inTableWithName: tableName) {
                //修改表明
                let  sql = "ALTER TABLE '" + tableName + "' RENAME TO 'old_Table'"
                do{
                    try db.executeUpdate(sql, values: nil)
                    //创建表
                    createTable(tableName: tableName, arFields: arFields, arFieldsType: arFieldsType)
                    //导入数据数据
                    importData(oldTableName: "old_Table", newTableName: tableName)
                    //删除旧表
                    dropTable(tableName: "old_Table")
                }catch{
                    print(db.lastErrorMessage())
                }
                
                
            }
            
        }
    }
    
    /// 导入数据
    ///
    /// - Parameters:
    ///   - oldTableName: 临时表名
    ///   - newTableName: 原表明（增加字段的表明）
    class func importData(oldTableName:String,newTableName:String)  {
        let db = getDatabase()
        if db.open() {
            let sql = "INSERT INTO " + newTableName + " SELECT  id,usedName, date, age, phone, ''  FROM " + oldTableName
            do{
                try db.executeUpdate(sql, values: nil)
            }catch{
                print(db.lastErrorMessage())
            }
        }
        
    }
    
    /// 新增加表字段
    ///
    /// - Parameter tableName: 表名
    class func changeTableWay1(tableName:String , addField:String,addFieldType:String)  {
        let db = getDatabase()
        if db.open() {
            let sql  = "ALTER TABLE " + tableName + " ADD " + addField + addFieldType
            do{
                try db.executeUpdate(sql, values: nil)
            }catch{
                print(db.lastErrorMessage())
            }
        }
    }
    
    /// 判断表是否存在
    ///
    /// -tableName : 表名称
    class func isTableExist(tableName : String)->Bool{
        let db = getDatabase()
        let sql = "select count(*) as 'count' from sqlite_master where type ='table' and name = ?"
        if db.open() {
            do {
                let rs = try db.executeQuery(sql, values: [tableName])
                while rs.next() {
                    let count = rs.int(forColumn: "count")
                    if count > 0{
                        return true
                    }else{
                        return false
                    }
                }
            } catch {
                print("failed : \(error.localizedDescription)")
            }
        }
        return false
    }
}
