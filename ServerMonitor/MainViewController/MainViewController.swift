//
//  MainViewController.swift
//  Swift_iPhone_demo
//
//  Created by Pandara on 14-7-2.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var serverData:JSON?
    var Index2Key = [0:"cpu",1:"mem",2:"hd"]
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tableView: UITableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pressGenerateFeatureButton(sender: AnyObject) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.Index2Key.count
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 30.0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        if !(cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        cell.textLabel!.text = self.Index2Key[indexPath.row]

        return cell
    }
    
    func tableView1(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var viewCon: UIViewController = UIViewController()
        viewCon.view.backgroundColor = UIColor.whiteColor()
        
        var chart: PDChart!
        
        switch indexPath.row {
        case 0:
            var lineChart: PDLineChart = self.getLineChart()
            chart = lineChart
            viewCon.view.addSubview(lineChart)
        case 1:
            getServerData()
//            var pieChart: PDPieChart = self.getPieChart()
            var pieChart: PDPieChart = self.generatePieChart(indexPath.row)
            chart = pieChart
            viewCon.view.addSubview(pieChart)
        case 2:
            var barChart: PDBarChart = self.getBarChart()
            chart = barChart
            viewCon.view.addSubview(barChart)
        default:
            break
        }
        
        chart.strokeChart()
        
        self.navigationController!.pushViewController(viewCon, animated: true)
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var viewCon: UIViewController = UIViewController()
        viewCon.view.backgroundColor = UIColor.whiteColor()
        
        var chart: PDChart!
        
        getServerData()
        var pieChart: PDPieChart = self.generatePieChart(indexPath.row)
        chart = pieChart
        viewCon.view.addSubview(pieChart)
        
        chart.strokeChart()
        
        self.navigationController!.pushViewController(viewCon, animated: true)
    }
    
    //获取数据
    func getServerData(){
        //创建socket
        var client:TCPClient = TCPClient(addr: "me.cc", port: 9505)
        //连接
        var (success,errmsg)=client.connect(timeout: 11)
        if success{
            //发送数据
            //            var (success,errmsg)=client.send(str:"GET / HTTP/1.0\n\n" )
            let jsonObject: [AnyObject] = [
                ["name": "John", "age": 21],
                ["name": "Bob", "age": 35],
            ]
            var sendStr = JSONStringify(jsonObject,prettyPrinted:false)
//            println(sendStr)
            var (success,errmsg)=client.send(str:sendStr )
            if success{
                //读取数据
                var returnData=client.read(1024*10)
//                println(returnData)
                if let d=returnData{
                    if let str=String.stringWithBytes(d,encoding:NSUTF8StringEncoding){
                        //                        var data = NSData(base64EncodedString:str,options:NSDataBase64DecodingOptions())
                        println(str)
//                        let nsstr = NSString(str)
                        let data = str.dataUsingEncoding(NSUTF8StringEncoding)
                        self.serverData = JSON(data: data!)
//                        self.serverData!.BooleanType
//                        println(self.serverData!.arrayCount)
//                        if let userName = self.serverData![0]["name"].stringValue {
//                            println(userName)
//                            
//                        }else{
//                            println("dd")
//                        }
                    }
                }
            }else{
                println(errmsg)
            }
        }else{
            println(errmsg)
        }
    
    }
    
    /**
    *   上传饼状图数据
    */
    
    func generatePieChart(index:Int) -> PDPieChart {     //data:JSON
        var key:String = self.Index2Key[index]!
        var dataItem: PDPieChartDataItem = PDPieChartDataItem()
        dataItem.pieWidth = 80
        dataItem.pieMargin = 50

        var count = self.serverData!.arrayCount
        
//        for key in 0...count {
//            var item = self.serverData![index]
//        
//        }
        var item = self.serverData![key]
        println(item["percent"].floatValue!)
        
        var persent = item["percent"].doubleValue!
        var freePercent = 1-persent
        println(freePercent)
        dataItem.dataArray = [
            PieDataItem(description: "Free \(freePercent*100)%", color: middleGreen, percentage: CGFloat(freePercent)),  //lightGreen
            PieDataItem(description: "Used \(persent*100)%", color: deepGreen, percentage: CGFloat(persent) )
        ]
        
        
        var pieChart: PDPieChart = PDPieChart(frame: CGRectMake(0, 100, 320, 320), dataItem: dataItem)
        return pieChart
        
    }
    

    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions.allZeros, error: nil) {
                //                if let string = NSString(data: data,  encoding: NSUTF8StringEncoding) {
                var string = NSString(data: data,  encoding: NSUTF8StringEncoding)
                return string
                //                }
            }
        }
        return ""
    }
    
//    func JSONDecode(data:NSData)-> AnyObject{
//        let jsonObject : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
//        if let statusesArray = jsonObject as? NSArray{
//            if let aStatus = statusesArray[0] as? NSDictionary{
//                if let user = aStatus["user"] as? NSDictionary{
//                    if let userName = user["name"] as? NSDictionary{
//                        //Finally We Got The Name
//                        
//                    }
//                }
//            }
//        }
//        return jsonObject
//    }
    
    
    
    func getLineChart() -> PDLineChart {
        var dataItem: PDLineChartDataItem = PDLineChartDataItem()
        dataItem.xMax = 7.0
        dataItem.xInterval = 1.0
        dataItem.yMax = 100.0
        dataItem.yInterval = 10.0
        dataItem.pointArray = [CGPoint(x: 1.0, y: 95.0), CGPoint(x: 2.0, y: 25.0), CGPoint(x: 3.0, y: 30.0), CGPoint(x: 4.0, y:50.0), CGPoint(x: 5.0, y: 55.0), CGPoint(x: 6.0, y: 60.0), CGPoint(x: 7.0, y: 90.0)]
        dataItem.xAxesDegreeTexts = ["周日", "一", "二", "三", "四", "五", "周六"]
        dataItem.yAxesDegreeTexts = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        
        var lineChart: PDLineChart = PDLineChart(frame: CGRectMake(0, 100, 320, 320), dataItem: dataItem)
        return lineChart
    }
    
    func getPieChart() -> PDPieChart {
        var dataItem: PDPieChartDataItem = PDPieChartDataItem()
        dataItem.pieWidth = 80
        dataItem.pieMargin = 50
        dataItem.dataArray = [PieDataItem(description: "first pie", color: lightGreen, percentage: 0.3),
                              PieDataItem(description: nil, color: middleGreen, percentage: 0.1),
                              PieDataItem(description: "third pie", color: deepGreen, percentage: 0.6)]
        var pieChart: PDPieChart = PDPieChart(frame: CGRectMake(0, 100, 320, 320), dataItem: dataItem)
        return pieChart
    }
    
    func getBarChart() -> PDBarChart {
        var dataItem: PDBarChartDataItem = PDBarChartDataItem()
        dataItem.xMax = 7.0
        dataItem.xInterval = 1.0
        dataItem.yMax = 100.0
        dataItem.yInterval = 10.0
        dataItem.barPointArray = [CGPoint(x: 1.0, y: 95.0), CGPoint(x: 2.0, y: 25.0), CGPoint(x: 3.0, y: 30.0), CGPoint(x: 4.0, y:50.0), CGPoint(x: 5.0, y: 55.0), CGPoint(x: 6.0, y: 60.0), CGPoint(x: 7.0, y: 90.0)]
        dataItem.xAxesDegreeTexts = ["周日", "一", "二", "三", "四", "五", "周六"]
        dataItem.yAxesDegreeTexts = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        
        var barChart: PDBarChart = PDBarChart(frame: CGRectMake(0, 100, 320, 320), dataItem: dataItem)
        return barChart
    }
}





















