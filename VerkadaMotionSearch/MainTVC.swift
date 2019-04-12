//  MainTVC.swift
//  VerkadaMotionSearch
//  Created by lordofming on 4/4/19.
//  Copyright © 2019 lordofming. All rights reserved.


/*
 Note:
 1. One red rectangle is drawn on image to show the rectangle circumscribing the UIBezierPath.
 2. Green rectangle(s) are drawn on image (laying on top of red rectangle) to show the cells that actually need to be searched.
 3. Pan Gesture on the image (to select search region) triggers the entire flow, no button or any other UI element to trigger action.
 4. Default search time window for every search is 1 hour, if no motion found in past 1 hour (i.e.search result is empty), search time window is incremented by 1 hour in each of the following attempts until a non-empty search result is obtained. Time window is capped at 12 hours, meaning no more HTTP POST requests to backend after trying time window of 12 hours, regardless of the search result.
 */

import UIKit
import Alamofire

protocol MotionSearchDelegate: class {
    func processSearch(cells: [[Int]])
    func clearTableView()
}

class MainTVC: UIViewController {
    
    fileprivate let NAV_BAR_TITLE = "Verkada Motion Search"

    fileprivate static let IMAGE_HEIGHT_TO_WIDTH_RATIO: CGFloat = 3 / 4
    
    fileprivate static let TABLE_VIEW_CONTENT_MIN_Y = Constants.SCREEN_WIDTH * IMAGE_HEIGHT_TO_WIDTH_RATIO
    fileprivate let TABLE_VIEW_HEIGHT = Constants.SCREEN_HEIGHT - TABLE_VIEW_CONTENT_MIN_Y
    
    fileprivate let Table_View_Background_Color = UIColor(red: 232, green: 232, blue: 232, alpha: 1)
    
    fileprivate let CAMERA_IMAGE_URL_STR = "http://ec2-54-187-236-58.us-west-2.compute.amazonaws.com:8021/ios/thumbnail/1550181934.jpg"
    fileprivate let POST_REQUEST_URL_STR = "http://ec2-54-187-236-58.us-west-2.compute.amazonaws.com:8021/ios/search"

    fileprivate let TIME_WINDOW_WIDTH_IN_SECOND_DEFAULT: TimeInterval = 3600
    fileprivate var TIME_WINDOW_WIDTH_IN_SECOND: TimeInterval = 3600
    fileprivate let MAX_TIME_WINDOW_WIDTH_IN_HOURS: TimeInterval = 12
    
    fileprivate var minYOfImage: CGFloat = 0

    fileprivate var imageFrame: CGRect!
    fileprivate var customImageView: CustomImageView!
    fileprivate var drawingView: DrawingView!
    
    fileprivate let customCellId = "customCellId"
    fileprivate let tableView = UITableView ()
    fileprivate var searchResultArray = [[Int]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NAV_BAR_TITLE

        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        self.minYOfImage = Constants.STATUS_BAR_HEIGHT + navBarHeight!

        imageFrame = CGRect(x:0, y: minYOfImage, width: self.view.bounds.width, height: self.view.bounds.width * MainTVC.IMAGE_HEIGHT_TO_WIDTH_RATIO)
        
        setupTableView()
        setupCustomImageView()
        setupDrawingView()
    }
    
    
    fileprivate func setupTableView(){
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
        
        tableView.frame = CGRect(x: 0, y: 0, width: Constants.SCREEN_WIDTH, height: self.view.bounds.height)

        tableView.register(CustomCell.self, forCellReuseIdentifier: customCellId)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: MainTVC.TABLE_VIEW_CONTENT_MIN_Y, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = Table_View_Background_Color
        
        self.view.addSubview(tableView)
        
        tableView.setAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: self.minYOfImage, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    
    fileprivate func setupCustomImageView(){
        self.customImageView = CustomImageView(frame: self.imageFrame)
        self.view.addSubview(self.customImageView)
        self.customImageView.loadImageUsingUrlString(CAMERA_IMAGE_URL_STR)
    }
    
    
    fileprivate func setupDrawingView(){
        self.drawingView = DrawingView(frame: self.imageFrame)
        self.drawingView.backgroundColor = UIColor.clear
        self.view.addSubview(self.drawingView)
        self.drawingView.motionSearchDelegate = self
    }
    
    fileprivate func formatTimeFromSecToString (unixTimeSec: Int64) -> String {
        let formatter = DateFormatter()
        let dateFromUnixTimeSec = Date(timeIntervalSince1970: TimeInterval(unixTimeSec))
        formatter.dateFormat = "HH:mm:ss , MM/dd/yyyy"
        return formatter.string(from: dateFromUnixTimeSec)
    }
    
}


extension MainTVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellId, for: indexPath) as! CustomCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        let item = self.searchResultArray[indexPath.item]
        
        cell.titleLabel.text = "Motion Occurred At  :  " + formatTimeFromSecToString(unixTimeSec: Int64(item[0]))
        
        let unit = item[1] <= 1 ? " second" : " seconds"
        
        cell.subTitleLabel.text = "Duration  :  " + String(item[1]) + unit
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}

extension MainTVC: MotionSearchDelegate {
    
    func clearTableView() {
        self.searchResultArray.removeAll()
        self.tableView.reloadData()
    }
    
    func processSearch(cells: [[Int]]){
        
        print("\n\nentered func processSearch(cells: [[Int]])\n\n")
        
        if self.TIME_WINDOW_WIDTH_IN_SECOND > self.MAX_TIME_WINDOW_WIDTH_IN_HOURS * self.TIME_WINDOW_WIDTH_IN_SECOND_DEFAULT {
            
            self.TIME_WINDOW_WIDTH_IN_SECOND = self.TIME_WINDOW_WIDTH_IN_SECOND_DEFAULT
            return
        }
        
        let parameters =  [
            "motionZones" : cells,
            "startTimeSec" : Date().timeIntervalSince1970 - TIME_WINDOW_WIDTH_IN_SECOND,
            "endTimeSec" : Date().timeIntervalSince1970
            ] as [String : Any]
        
        //this Alamofire request is async.
        Alamofire.request(POST_REQUEST_URL_STR, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseJSON { [weak self] response in
            
            print("\n\ntype of response is:\(type(of: response))\n\n")
            print("\n\nresponse is:\(response)\n\n")
            print("\n\nresponse.result is:\(response.result)\n\n")
            print("\n\nresponse.response?.statusCode is:\(String(describing: response.response?.statusCode))\n\n")
            print("\n\nresponse.result.value is:\(String(describing: response.result.value))\n\n")
            
            switch response.result {
                
                
            /*
                 In Swift, enums can have associated values (docs). This means, that you can associate an object with cases. The part (let dict) simply means - take the associated value, and put in in a let constant named dict.
                 ref: https://stackoverflow.com/questions/43140804/what-does-it-mean-in-swift-case-successlet-dict
                 */
            case .success (let JSON):
                
                let statusCode = (response.response?.statusCode)!
                
                if statusCode >= 200 && statusCode < 300 {
                    
                    print("Success with JSON: \(JSON)")
                    
                    let response = JSON as! NSDictionary
                    let result2DArray = response.object(forKey: "motionAt")! as! [[Int]]
                    
                    if result2DArray.isEmpty{
                        self?.TIME_WINDOW_WIDTH_IN_SECOND += (self?.TIME_WINDOW_WIDTH_IN_SECOND_DEFAULT)!
                        self?.processSearch(cells: cells)
                        return
                    }
                    
                    self?.searchResultArray = result2DArray
                    self?.tableView.reloadData()
                    
                    self?.TIME_WINDOW_WIDTH_IN_SECOND = (self?.TIME_WINDOW_WIDTH_IN_SECOND_DEFAULT)!

                }else{
                    Ui.showMessageDialog(onController: self!, withTitle: "Unexpected status code",
                                         withMessage: "Status code of HTTP request is outside of 200 ~ 300.", autoDismissAfter: 5)
                    
                    print("Sucess, statusCode is outside of 200 ~ 300")
                }
                
                break
                
            case .failure(let error):
                
                Ui.showMessageDialog(onController: self!, withTitle: "Motion Search Failed",
                                     withMessage: "Response of HTTP request is failure .", autoDismissAfter: 5)
                
                print("response.result is failure, error: \(error.localizedDescription)\n\n")
                
            }//end of switch
            
        }//end of Alamofire.request()
        
    }//end of func processSearch()
    
}//end of extension
