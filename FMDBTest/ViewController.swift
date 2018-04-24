//
//  ViewController.swift
//  FMDBTest
//
//  Created by pxh on 2018/4/23.
//  Copyright © 2018年 pxh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let fields = ["name","age","sex","class"]

        let fieldTypes = ["String","Int","Bool","String"]
        FMDBManager.createTable(tableName: "Person", arFields: fields as NSArray, arFieldsType: fieldTypes as NSArray)
        let dicFields : NSDictionary = ["name":"pxh","age":40,"sex":true,"class":"三年级二班","id":2001]
//        dicFields.setValue("pxh", forKey: "name")
//        dicFields.setValue("40", forKey: "age")
//        dicFields.setValue("true", forKey: "sex")
//        dicFields.setValue("三年级二班", forKey: "class")
//        dicFields.setValue("pxh", forKey: "name")
        
        FMDBManager.insertDataToTable(tableName: "Person", dicFields: dicFields)


        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let fields = ["name","age","sex","class","id"]
            let dict = FMDBManager.selectFromTable(tableName: "Person", arFieldsKey: fields as NSArray)
            print(dict.description)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

