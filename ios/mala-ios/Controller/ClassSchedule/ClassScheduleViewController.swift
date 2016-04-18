//
//  ClassScheduleViewController.swift
//  mala-ios
//
//  Created by 王新宇 on 3/5/16.
//  Copyright © 2016 Mala Online. All rights reserved.
//

import UIKit
import DateTools

private let ClassScheduleViewCellReuseID = "ClassScheduleViewCellReuseID"
private let ClassScheduleViewHeaderReuseID = "ClassScheduleViewHeaderReuseID"
private let kCalendarUnitYMD: NSCalendarUnit = [.Year, .Month, .Day]

public class ClassScheduleViewController: ThemeCalendarViewController, ThemeCalendarViewDelegate, ClassScheduleViewCellDelegate {

    // MARK: - Property
    /// 上课时间表数据模型
    var model: [Int:[Int:[StudentCourseModel]]]? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
                self?.collectionView?.reloadData()
            }
        }
    }
    /// 当前月份
    private let currentMonth = NSDate().month()
    
    

    // MARK: - Components
    /// 保存按钮
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton(
            title: "今天",
            titleColor: MalaColor_82B4D9_0,
            target: self,
            action: #selector(ClassScheduleViewController.scrollToToday)
        )
        saveButton.setTitleColor(MalaColor_E0E0E0_95, forState: .Disabled)
        return saveButton
    }()
    
    // MARK: - Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadStudentCourseTable()
    }

    // MARK: - Private Method
    private func configure() {
        // Calendar
        delegate = self
        weekdayHeaderEnabled = true
        
        // rightBarButtonItem
        let spacerRight = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        spacerRight.width = -MalaLayout_Margin_5
        let rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItems = [rightBarButtonItem, spacerRight]
        
        // register
        collectionView?.registerClass(ClassScheduleViewCell.self, forCellWithReuseIdentifier: ClassScheduleViewCellReuseID)
        collectionView?.registerClass(ClassScheduleViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ClassScheduleViewHeaderReuseID)
    }
    
    ///  获取学生可用时间表
    private func loadStudentCourseTable() {
        
        // 课表页面允许用户未登录时查看，此时仅作为日历展示
        if !MalaUserDefaults.isLogined {
            
            // 若在注销后存在课程数据残留，清除数据并刷新日历
            if model != nil {
                model = nil
                collectionView?.reloadData()
            }
            return
        }
        
        // 发送网络请求
        getStudentCourseTable(failureHandler: { (reason, errorMessage) -> Void in
            defaultFailureHandler(reason, errorMessage: errorMessage)
            // 错误处理
            if let errorMessage = errorMessage {
                println("ClassSecheduleViewController - loadStudentCourseTable Error \(errorMessage)")
            }
        }, completion: { [weak self] (courseList) -> Void in
            println("学生课程表: \(courseList)")
            guard courseList != nil else {
                println("学生上课时间表为空！")
                return
            }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self?.model = parseStudentCourseTable(courseList!)
                self?.scrollToToday()
            }
        })
    }
    
    
    // MARK: - DataSource
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ClassScheduleViewCellReuseID, forIndexPath: indexPath) as! ClassScheduleViewCell
        cell.delegate = self
        
        let firstOfMonth = self.firstOfMonthForSection(indexPath.section)
        let cellDate = self.dateForCellAtIndexPath(indexPath)
        
        
        let cellDateComponents = self.calendar.components(kCalendarUnitYMD, fromDate: cellDate)
        let firstOfMonthsComponents = self.calendar.components(kCalendarUnitYMD, fromDate: firstOfMonth)

        var isToday = false
        var isSelected = false
        var isCustomDate: Bool? = false
        
        if cellDateComponents.month == firstOfMonthsComponents.month {
            isSelected = self.isSelectedDate(cellDate) && (indexPath.section == self.sectionForDate(cellDate))
            isToday = self.isTodayDate(cellDate)
            cell.setDate(date: cellDate, calendar: self.calendar)
            isCustomDate = self.delegate?.calendarViewControllerShouldUseCustomColorsForDate?(self, date: cellDate)
        }else {
            cell.setDate(date: nil, calendar: nil)
        }
        
        if isToday {
            cell.isToday = isToday
        }

        if isSelected {
            cell.selected = isSelected
        }
        
        if self.isEnabledDate(cellDate) || (isCustomDate == true) {
            cell.refreshCellColors()
        }
        
        // 若存在上课时间数据, 渲染Cell样式
        if
            let year = cell.date?.year(),
            let month = cell.date?.month(),
            let day = cell.date?.day(),
            let course = model?[month]?[day] where course.first?.date.year() == year {
            cell.models = course
        }
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        return cell
    }
    
    
    // MARK: - Delegate
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ClassScheduleViewCell
        let models = cell.models
        
        // 若cell存在日期数据，弹出课程窗口
        if models.count != 0 {
            
            /// 当天课程视图
            let contentView = CourseContentView()
            contentView.studentCourses = models
            
            /// 弹出窗口
            let popupWindow = CoursePopupWindow(contentView: contentView)
            popupWindow.isPassed = models[0].is_passed
            popupWindow.titleDate = models[0].date
            popupWindow.show()
        }
    }
    
    
    // MARK: - ClassScheduleViewCell Delegate
    public func classScheduleViewCell(cell: ClassScheduleViewCell, shouldUseCustomColorsForDate date: NSDate) -> Bool {
        if self.isEnabledDate(date) {
            return true
        }
        return self.delegate?.calendarViewControllerShouldUseCustomColorsForDate?(self, date: date) ?? false
    }
    
    public func classScheduleViewCell(cell: ClassScheduleViewCell, circleColorForDate date: NSDate) -> UIColor? {
        if self.isEnabledDate(date) {
            return cell.circleDefaultColor
        }
        return self.delegate?.calendarViewControllerCircleColorForDate?(self, date: date)
    }
    
    public func classScheduleViewCell(cell: ClassScheduleViewCell, textColorForDate date: NSDate) -> UIColor? {
        if self.isEnabledDate(date) {
            return cell.textDisabledColor
        }
        return self.delegate?.calendarViewControllerTextColorForDate?(self, date: date)
    }
    
    
    // MARK: - Event Response
    @objc private func scrollToToday() {
        scrollToDate(NSDate(), animated: true)
    }
}