//
//  CourseTableViewSectionHeader.swift
//  mala-ios
//
//  Created by 王新宇 on 16/6/14.
//  Copyright © 2016年 Mala Online. All rights reserved.
//

import UIKit

class CourseTableViewSectionHeader: UITableViewHeaderFooterView {

    // MARK: - Property
    /// 日期数据
    var timeInterval: NSTimeInterval? = 0 {
        didSet {
            /// 同年日期仅显示月份，否则显示年月
            let formatter = NSDate(timeIntervalSince1970: timeInterval ?? 0).year() == NSDate().year() ? "M月" : "yyyy年M月"
            dateLabel.text = getDateString(timeInterval, format: formatter)
        }
    }
    /// 所属TableView
    var parentTableView: UITableView?
    /// 高度比率, 应属于[1, 2], 默认为1.5
    var parallaxRatio: CGFloat = 2 {
        didSet {
            parallaxRatio = max(parallaxRatio, 1.0)
            parallaxRatio = min(parallaxRatio, 2.0)
            
            var rect = self.bounds
            rect.size.height = rect.size.height*parallaxRatio
            parallaxImage.frame = rect
            updateParallaxOffset()
        }
    }
    
    
    // MARK: - Components
    /// 视差图片
    lazy var parallaxImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "course_header"))
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    /// 时间文本标签
    private lazy var dateLabel: UILabel = {
        let label = UILabel(
            text: "",
            fontSize: 20,
            textColor: MalaColor_000000_0
        )
        return label
    }()
    
    // MARK: - Constructed
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupUserInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private
    private func setupUserInterface() {
        // Style
        contentView.clipsToBounds = true
        
        // SubViews
        contentView.addSubview(parallaxImage)
        contentView.sendSubviewToBack(parallaxImage)
        contentView.addSubview(dateLabel)
        
        // AutoLayout
        dateLabel.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(contentView.snp_left).offset(70)
            make.bottom.equalTo(contentView.snp_bottom).offset(-20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.parallaxRatio = self.parallaxRatio
//        return
    }
    
    ///  添加观察者
    private func safeAddObserver() {
        if let tableView = parentTableView {
            tableView.addObserver(self, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
        }
    }
    
    ///  移除观察者
    private func safeRemoveObserver() {
        if let tableView = parentTableView {
            tableView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
        }
    }
    
    ///  将从父视图中移除
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        safeRemoveObserver()
        
        var view = newSuperview
        
        while (view != nil) {
            if view is UITableView {
                parentTableView = view as? UITableView
                break
            }
            view = view?.superview
        }
        safeAddObserver()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let key = keyPath where key == "contentOffset" {
            self.updateParallaxOffset()
        }
    }
    
    ///  移除父视图
    override func removeFromSuperview() {
        super.removeFromSuperview()
        safeRemoveObserver()
    }
    
    ///  更新图片视差偏移量
    private func updateParallaxOffset() {
        
        let contentOffset = parentTableView?.contentOffset.y
        var cellOffset = contentView.frame.origin.y - (contentOffset ?? 0)
        
        let percent = (cellOffset + contentView.frame.size.height)/((parentTableView?.frame.size.height ?? 0) + contentView.frame.size.height)
        let extraHeight = contentView.frame.size.height*(parallaxRatio-1)
        
        var rect = contentView.frame
        rect.size.width = contentView.frame.width
        rect.size.height = 420
        rect.origin.y = -extraHeight*percent-210
        
        println("Frame - \(rect) - \(percent) - \(contentOffset) - \(cellOffset)")
        
        parallaxImage.frame = rect
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        parallaxImage.frame.origin.y = -100
    }
    
    
    deinit {
        self.safeRemoveObserver()
    }
}