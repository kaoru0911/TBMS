//
//  ProduceScrollViewWithVCArray.sw/Volumes/Swift/Play Ground/ScrollViewPracticeift
//  CaluculatePractice
//
//  Created by 倪僑德 on 2017/3/30.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import Foundation
import UIKit

class ProduceScrollViewWithVCArray: NSObject {
    //宣告scrollView/pageControll/CGSize
    var pagingScrollingVC : ScrollVC!
    var myScrollView : UIScrollView!
    var pageChanged : UIPageControl!
    var fullSize : CGSize!
    var pageControlDotExist = false {
        willSet {
            fullSize = pagingScrollingVC.fullSize
            myScrollView = pagingScrollingVC.myScrollView
            addPageControl()
        
        }
    }
    var vcInput: [UIViewController?]! = []
    
    //對PageControl的Dot設定
    var currentPageIndicatorTintColorSetting = UIColor.black
    var otherPageIndicatorTintColorSetting = UIColor.lightGray
    
    //初始化時建立好scrollView並匯入VC
    init(vcArrayInput:[UIViewController?]!) {
        super.init()
        print("initializer with vcArrayInput is running!!")
        
        //確認Input的VC array與ＶＣ都無異常
        guard vcArrayInput != nil else {
            print("vcArrayInput == nil")
            return
        }
        for i in 0...vcArrayInput.count-1{
            guard vcArrayInput[i] != nil else {
                print("vc\(i) doesn't exist!")
                return
            }
        }
        pagingScrollingVC = ScrollVC()
        pagingScrollingVC.vcInput = vcArrayInput
    }
    
    
    
    //-------建立UIPageControl-------------
    func addPageControl(){
        print("addPageControl is running")
        pagingScrollingVC.pageControllCheckPoint = true
        //建立UIPageControl的位置＆尺寸
        //1. 實體化UIPageControl並指定UIPageControl感應範圍
        pagingScrollingVC.pageChanged = UIPageControl(frame:(CGRect(x: 0, y: 0, width: 2 , height: 50)))
        guard pagingScrollingVC.pageChanged != nil else {
            print("pageChanged = nil")
            return
        }
        
        //2. 設定UIPageControl的中心點
        pagingScrollingVC.pageChanged.center = CGPoint(x: fullSize.width*0.5, y: fullSize.height*0.86)
        
        //設定頁面
        //1. 設定總共的頁面數, 也可直接用Int(totalVCNumber)
        pagingScrollingVC.pageChanged.numberOfPages = Int(myScrollView.contentSize.width/myScrollView.frame.width)
        //2. 設定起始的頁面
        pagingScrollingVC.pageChanged.currentPage = 0
        
        //設定點點
        //1. 設定所在頁面的點點顏色
        pagingScrollingVC.pageChanged.currentPageIndicatorTintColor = currentPageIndicatorTintColorSetting
        //2. 設定其餘頁面點點的顏色
        pagingScrollingVC.pageChanged.pageIndicatorTintColor = otherPageIndicatorTintColorSetting
        
        //其餘設定
        //1. 增加在UIPageControl值變換時引發的動作 (for:valueChanged)
        pagingScrollingVC.pageChanged.addTarget(pagingScrollingVC, action: #selector(pagingScrollingVC.pageChanged(_:)), for: .valueChanged)
        //2. 將UIPageControll加到底部畫面上
        pagingScrollingVC.view.addSubview(pagingScrollingVC.pageChanged)
        
    }
}

class ScrollVC: UIViewController, UIScrollViewDelegate{
    //宣告scrollView/pageControll/CGSize
    var myScrollView : UIScrollView!
    var pageChanged : UIPageControl!
    var fullSize : CGSize!
    var pageControllCheckPoint = false
    var totalVCNumbers : Int! = 1
    var vcInput: [UIViewController?]? = [] {
        willSet{
            print("VC Array has been input")
            guard let newValue = newValue else {
                print("vcInput=nil")
                return
            }
            
            for i in 0...newValue.count-1 {
                let vc = newValue[i]
                guard vc != nil else {
                    print("vc\(i+1) doesn't exist.")
                    return
                }
            }
            totalVCNumbers = newValue.count
            //建置UIScrollView
            myScrollView = UIScrollView()
            //畫面設定：
            //1. 取得畫面尺寸
            fullSize = UIScreen.main.bounds.size
            //2. 設置整個UIScrollView的大小
            myScrollView.contentSize = CGSize(width: fullSize.width * CGFloat(totalVCNumbers), height: fullSize.height)
            //3. 設置可見視圖尺寸&位置
            myScrollView.frame = CGRect(x: 0, y: 0, width: fullSize.width, height: fullSize.height)
            
            //設定細節：
            //1. 滑動條？
            myScrollView.showsVerticalScrollIndicator = false
            myScrollView.showsHorizontalScrollIndicator = false
            //2. 超出範圍要否彈回動畫
            myScrollView.bounces = true
            //3. 設定滑動方式
            myScrollView.isPagingEnabled = true
            
            //其他設定：
            //1. 設定委任對象（記得簽protocol）
            myScrollView.delegate = self
            //2. 加到畫面中
            self.view.addSubview(myScrollView)//這邊應該可直接拉scrollView的IBOutlet
            
            //-------將ＶＣ帶到畫面上
            addVCToScrollVC(VCs: newValue as! [UIViewController])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addVCToScrollVC(VCs:[UIViewController]!) {
        print("func addVCToScrollVC is running now")
        guard VCs != nil else {
            print("Func addVCToScrollVC has no vcArray input")
            return
        }
        for vc in VCs {
            let i = CGFloat(VCs.index(of: vc)!)
            addChildViewController(vc)
            myScrollView.addSubview(vc.view)
            vc.view.frame = CGRect(x: fullSize.width * i, y: 0, width: fullSize.width, height: fullSize.height)
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard pageControllCheckPoint else {
            print("pageControll not exist")
            return
        }
        print("func scrollViewDidEndDecelerating is running!")
        var page = Int(scrollView.contentOffset.x/scrollView.frame.width)
//        print(page)
        if page <= 0 {
            page = 0
        } else if page > totalVCNumbers{
            page = totalVCNumbers
        }
        guard pageChanged != nil else {
            print("pageChanged is nil")
            return
        }
//        print(page)
        pageChanged.currentPage = page
    }
    
    func pageChanged(_ sender:UIPageControl){
        print("func pageChanged is running")
        // 依照目前圓點在的頁數算出位置
        var frame = myScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0
        // 再將 UIScrollView 滑動到該點
        myScrollView.scrollRectToVisible(frame, animated:true)
    }
}
