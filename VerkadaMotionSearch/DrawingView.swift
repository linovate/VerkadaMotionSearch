//  DrawingView.swift
//  VerkadaMotionSearch
//  Created by lordofming on 4/4/19.
//  Copyright © 2019 lordofming. All rights reserved.

import UIKit

class DrawingView: UIView {
    
    weak var motionSearchDelegate: MotionSearchDelegate?
    
    fileprivate var bezierPathLine: UIBezierPath?
    
    fileprivate let NUM_OF_COLUMNS_SEARCH_CELL: CGFloat = 10
    fileprivate let NUM_OF_ROW_SEARCH_CELL: CGFloat = 10
    
    fileprivate var searchCellWidth: CGFloat = 0
    fileprivate var searchCellHeight: CGFloat = 0
    
    fileprivate let PATH_LINE_WIDTH: CGFloat = 4

    fileprivate var pathCellsSet: Set<[Int]> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
        searchCellWidth = self.bounds.width / NUM_OF_COLUMNS_SEARCH_CELL
        searchCellHeight = self.bounds.height / NUM_OF_ROW_SEARCH_CELL
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }
    
    override func draw(_ rect: CGRect) {
        drawLine()
    }
    
    fileprivate func drawLine() {
        UIColor.blue.setStroke()
        bezierPathLine?.stroke()
    }
    
    fileprivate func initDrawing() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        bezierPathLine = nil
        setNeedsDisplay()
        bezierPathLine = UIBezierPath()
        bezierPathLine?.lineWidth = PATH_LINE_WIDTH
        pathCellsSet.removeAll()
        
        motionSearchDelegate?.clearTableView()
    }
    
    fileprivate func initializeView() {
        isMultipleTouchEnabled = false
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(viewDragged))        
        addGestureRecognizer(panGR)
    }
    
    @objc func viewDragged(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.location(in: self)
        
        if point.x < 0 || point.x > frame.width || point.y < 0 || point.y > frame.height {
            return
        }
        
        addPathCell(point: point)
        
        switch sender.state {
            
            case .began:
                initDrawing()
                bezierPathLine?.move(to: point)
                break
            
            case .changed:
                bezierPathLine?.addLine(to: point)
                setNeedsDisplay()
                break
            
            case .ended:
                handleDrawing()
                break
            
            default:
                break
        }
    }
    
    
    fileprivate func addPathCell(point: CGPoint) {
        
        let colNum = Int(floor(point.x/searchCellWidth))
        let rowNum = Int(floor(point.y/searchCellHeight))
        
        pathCellsSet.insert([colNum,rowNum])
    }
    
    
    fileprivate func handleDrawing() {
        
        let boundingRect = bezierPathLine?.bounds
        
        if boundingRect == nil{
            
            Ui.showMessageDialog(onController: motionSearchDelegate as! UIViewController, withTitle: "Error", withMessage: "Something wrong with identifying boundingRect.", autoDismissAfter: 5)
            
            print("boundingRect == nil in func handleDrawing()")
            return
        }
        
        let boundingRectView = UIView(frame:boundingRect!)
        self.addSubview(boundingRectView)
        boundingRectView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        
        processBoundingRect(rect: boundingRect!)
    }
    
    
    fileprivate func processBoundingRect(rect: CGRect){
        
        let minCol = Int(floor(rect.minX/searchCellWidth))
        let minRow = Int(floor(rect.minY/searchCellHeight))
        let maxCol = Int(floor(rect.maxX/searchCellWidth))
        let maxRow = Int(floor(rect.maxY/searchCellHeight))
        
        var searchCellsArray = [[Int]]()
        
        for i in minRow...maxRow {
            
            var colOfFirstTouchOfLine: Int = -1
            var colOfLastTouchOfLine: Int = -1
            
            for j in minCol...maxCol {
                
                if pathCellsSet.contains([j,i]){
                    
                    searchCellsArray.append([j,i])
                    
                    if colOfFirstTouchOfLine == -1{
                        colOfFirstTouchOfLine = j
                    }
                    
                    colOfLastTouchOfLine = j
                    
                }else if colOfFirstTouchOfLine > -1{
                    searchCellsArray.append([j,i])
                }
                
            }//end of inner for loop
            
            let numOfExtraTrailingCells = maxCol - colOfLastTouchOfLine
            
            if numOfExtraTrailingCells > 0 && numOfExtraTrailingCells <= maxCol{
                
                //checking numOfExtraTrailingCells <= maxCol + 1 should not be necessary, but play safe here.
                searchCellsArray.removeLast(numOfExtraTrailingCells)
            }
            
        }//end of outer for loop
        
        print("\n\nsearchCellsArray size after removing trailing cells: \(searchCellsArray.count)\n\n")
        print("\n\nsearchCellsArray: \(searchCellsArray)\n\n")

        //For displaying actual cells that need to be searched. Good for checking correctness.
        for cell in searchCellsArray {
            
            let frame = CGRect(x: CGFloat(cell[0]) * searchCellWidth, y: CGFloat(cell[1]) * searchCellHeight, width: searchCellWidth, height: searchCellHeight)
            
            let searchCellRectView = UIView(frame:frame)
    
            self.addSubview(searchCellRectView)
            
            searchCellRectView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        }
        
        motionSearchDelegate?.processSearch(cells: searchCellsArray)
        
    }//end of processBoundingRect()
    
}
