import Foundation
import SwiftUI

enum Language: String, CaseIterable {
    case chinese = "zh-Hans"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

@MainActor
class LanguageService: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
        }
    }
    
    static let shared = LanguageService()
    
    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? Language.chinese.rawValue
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .chinese
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
    }
}

// 本地化字符串扩展
extension String {
    @MainActor
    func localized(_ language: Language? = nil) -> String {
        let lang = language ?? LanguageService.shared.currentLanguage
        
        if lang == .chinese {
            return LocalizedStrings.chinese[self] ?? self
        } else {
            return LocalizedStrings.english[self] ?? self
        }
    }
    
    // 非MainActor版本，用于需要的地方
    func localizedSync(_ language: Language) -> String {
        if language == .chinese {
            return LocalizedStrings.chinese[self] ?? self
        } else {
            return LocalizedStrings.english[self] ?? self
        }
    }
}

// 本地化字符串字典
struct LocalizedStrings {
    static let chinese: [String: String] = [
        // App
        "app.name": "AI考勤系统",
        "app.slogan": "智能打卡，高效管理",
        
        // Language Selection
        "language.select": "请选择语言 / Please Select Language",
        "language.chinese": "中文",
        "language.english": "English",
        "language.continue": "继续",
        
        // Login
        "login.welcome": "欢迎登录",
        "login.employeeId": "请输入员工号",
        "login.password": "请输入密码",
        "login.button": "登录",
        "login.faceLogin": "人脸快速登录",
        "login.firstTime": "首次登录请使用员工号和初始密码",
        "login.forgotPassword": "忘记密码请联系管理员",
        "login.failed": "登录失败",
        "login.errorMessage": "员工号或密码错误",
        
        // Tabs
        "tab.attendance": "打卡",
        "tab.records": "记录",
        "tab.statistics": "统计",
        "tab.profile": "我的",
        "tab.dashboard": "仪表板",
        "tab.employees": "员工",
        "tab.approval": "审批",
        "tab.settings": "设置",
        "tab.aiChat": "AI助手",
        
        // Attendance
        "attendance.title": "AI打卡",
        "attendance.currentUser": "当前用户",
        "attendance.admin": "管理员",
        "attendance.employee": "普通员工",
        "attendance.checkIn": "上班打卡",
        "attendance.checkOut": "下班打卡",
        "attendance.workTime": "上班时间",
        "attendance.offTime": "下班时间",
        "attendance.workDuration": "工作时长",
        "attendance.photoVerified": "拍照打卡",
        "attendance.selectMethod": "选择打卡方式",
        "attendance.normalCheckIn": "普通打卡",
        "attendance.photoCheckIn": "拍照打卡",
        "attendance.cancel": "取消",
        "attendance.faceToCamera": "请正对摄像头拍照",
        "attendance.startCheckIn": "开始打卡",
        
        // Records
        "records.title": "打卡记录",
        "records.today": "今天",
        "records.thisWeek": "本周",
        "records.thisMonth": "本月",
        "records.lastMonth": "上月",
        "records.custom": "自定义",
        "records.noRecords": "暂无打卡记录",
        "records.noRecordsDesc": "该时间段内没有打卡记录",
        "records.normal": "正常",
        "records.late": "迟到",
        "records.checkInRecord": "上班打卡",
        "records.checkOutRecord": "下班打卡",
        "records.workHours": "工作%.1f小时",
        
        // Statistics
        "statistics.title": "统计分析",
        "statistics.monthlyOverview": "本月考勤概览",
        "statistics.shouldAttend": "应出勤",
        "statistics.actualAttend": "实际出勤",
        "statistics.attendanceRate": "出勤率",
        "statistics.normalAttend": "正常出勤",
        "statistics.completeDays": "完整工作日",
        "statistics.late": "迟到",
        "statistics.earlyLeave": "早退",
        "statistics.absent": "缺勤",
        "statistics.leave": "请假",
        "statistics.overtime": "加班",
        "statistics.photoCheckIn": "拍照打卡",
        "statistics.verified": "已验证",
        "statistics.verificationRate": "验证率",
        "statistics.workHourStats": "工作时长统计",
        "statistics.dailyAverage": "日均工时",
        "statistics.totalHours": "总工时",
        
        // Profile
        "profile.title": "我的",
        "profile.personalInfo": "个人信息",
        "profile.faceManagement": "人脸信息管理",
        "profile.notifications": "消息通知",
        "profile.leaveApplication": "请假申请",
        "profile.makeupApplication": "补卡申请",
        "profile.myApplications": "我的申请",
        "profile.settings": "设置",
        "profile.help": "帮助与反馈",
        "profile.logout": "退出登录",
        "profile.confirmLogout": "确定要退出登录吗？",
        "profile.version": "版本",
        "profile.developer": "开发者",
        "profile.developerName": "AI打卡系统团队",
        
        // Admin Dashboard
        "dashboard.title": "管理仪表板",
        "dashboard.realTimeData": "今日实时数据",
        "dashboard.checkedIn": "已到岗人数",
        "dashboard.checkInRate": "到岗率",
        "dashboard.departmentOverview": "部门考勤概况",
        "dashboard.pendingTasks": "待处理事项",
        "dashboard.pendingLeave": "待审批请假",
        "dashboard.pendingMakeup": "待处理补卡",
        "dashboard.attendanceTrend": "今日打卡时段分布",
        "dashboard.abnormalAttendance": "异常考勤",
        "dashboard.viewAll": "查看全部",
        "dashboard.techDept": "技术部",
        "dashboard.marketDept": "市场部",
        "dashboard.adminDept": "行政部",
        "dashboard.financeDept": "财务部",
        "dashboard.hrDept": "人事部",
        
        // Employee Management
        "employee.title": "员工管理",
        "employee.search": "搜索员工姓名或工号",
        "employee.total": "共 %d 名员工",
        "employee.add": "添加员工",
        "employee.notFound": "没有找到员工",
        "employee.adjustSearch": "尝试调整搜索条件",
        "employee.basicInfo": "基本信息",
        "employee.name": "姓名",
        "employee.id": "工号",
        "employee.department": "部门",
        "employee.position": "职位",
        "employee.accountSettings": "账号设置",
        "employee.initialPassword": "初始密码",
        "employee.sendWelcomeEmail": "发送欢迎邮件",
        "employee.save": "保存",
        "employee.edit": "编辑信息",
        "employee.viewRecords": "查看考勤记录",
        "employee.resetPassword": "重置密码",
        "employee.delete": "删除员工",
        "employee.people": "人",
        
        // Approval Center
        "approval.title": "审批中心",
        "approval.pending": "待审批",
        "approval.approved": "已审批",
        "approval.all": "全部",
        "approval.noPending": "暂无待审批事项",
        "approval.noPendingDesc": "所有申请都已处理完成",
        "approval.noApproved": "暂无已审批记录",
        "approval.noApprovedDesc": "审批的记录将显示在这里",
        "approval.leaveRequest": "请假申请",
        "approval.makeupRequest": "补卡申请",
        "approval.overtimeRequest": "加班申请",
        "approval.businessTrip": "出差申请",
        "approval.approve": "同意",
        "approval.reject": "拒绝",
        "approval.rejectReason": "拒绝理由",
        "approval.confirmReject": "确定拒绝",
        "approval.applicationType": "申请类型",
        "approval.startTime": "开始时间",
        "approval.endTime": "结束时间",
        "approval.reason": "申请理由",
        "approval.submitTime": "提交时间",
        "approval.approvalTime": "审批时间",
        "approval.status.pending": "待审批",
        "approval.status.approved": "已通过",
        "approval.status.rejected": "已拒绝",
        
        // Leave Application
        "leave.title": "请假申请",
        "leave.type": "请假类型",
        "leave.personal": "事假",
        "leave.sick": "病假",
        "leave.annual": "年假",
        "leave.compensatory": "调休",
        "leave.startTime": "开始时间",
        "leave.endTime": "结束时间",
        "leave.duration": "请假时长",
        "leave.reason": "请假事由",
        "leave.reasonPlaceholder": "请输入请假事由...",
        "leave.approver": "审批人",
        "leave.submit": "提交申请",
        "leave.submitSuccess": "提交成功",
        "leave.submitSuccessDesc": "您的请假申请已提交，请等待审批",
        "leave.confirm": "确定",
        
        // Makeup Application
        "makeup.title": "补卡申请",
        "makeup.date": "补卡日期",
        "makeup.type": "补卡类型",
        "makeup.checkIn": "上班补卡",
        "makeup.checkOut": "下班补卡",
        "makeup.both": "全天补卡",
        "makeup.time": "补卡时间",
        "makeup.reason": "补卡原因",
        "makeup.reasonPlaceholder": "请输入补卡原因...",
        "makeup.quickSelect": "快速选择",
        "makeup.systemError": "系统故障，无法正常打卡",
        "makeup.forgot": "忘记打卡",
        "makeup.networkIssue": "网络连接问题，打卡失败",
        "makeup.other": "其他",
        "makeup.evidence": "证明材料",
        "makeup.addPhoto": "添加照片证明（可选）",
        "makeup.submit": "提交申请",
        "makeup.submitSuccess": "提交成功",
        "makeup.submitSuccessDesc": "您的补卡申请已提交，请等待审批",
        
        // Settings
        "settings.title": "设置",
        "settings.workTime": "工作时间",
        "settings.startTime": "上班时间",
        "settings.endTime": "下班时间",
        "settings.features": "功能设置",
        "settings.enablePhoto": "启用拍照打卡",
        "settings.enableNotifications": "启用通知提醒",
        "settings.defaultLocation": "默认位置",
        "settings.inputLocation": "输入位置",
        "settings.dataManagement": "数据管理",
        "settings.exportData": "导出数据",
        "settings.clearData": "清除所有数据",
        "settings.clearDataWarning": "此操作将删除所有打卡记录，且无法恢复。",
        "settings.about": "关于",
        "settings.adminFeatures": "管理员功能",
        "settings.userManagement": "用户管理",
        "settings.systemSettings": "系统设置",
        "settings.auditLog": "审计日志",
        "settings.attendanceRules": "考勤规则设置",
        "settings.basicSettings": "基本设置",
        "settings.lateToleranceMinutes": "迟到容忍时间（分钟）",
        "settings.aiSettings": "AI识别设置",
        "settings.enableLivenessDetection": "启用活体检测",
        "settings.recognitionAccuracy": "识别精度",
        "settings.high": "高",
        "settings.medium": "中",
        "settings.low": "低",
        "settings.allowMaskRecognition": "允许戴口罩识别",
        "settings.saveSettings": "保存设置",
        
        // Common
        "common.ok": "确定",
        "common.cancel": "取消",
        "common.save": "保存",
        "common.delete": "删除",
        "common.edit": "编辑",
        "common.submit": "提交",
        "common.confirm": "确认",
        "common.back": "返回",
        "common.close": "关闭",
        "common.loading": "加载中...",
        "common.error": "错误",
        "common.success": "成功",
        "common.warning": "警告",
        "common.info": "信息",
        "common.all": "全部",
        "common.none": "无",
        "common.select": "选择",
        "common.selected": "已选择",
        "common.unselected": "未选择",
        "common.search": "搜索",
        "common.filter": "筛选",
        "common.sort": "排序",
        "common.refresh": "刷新",
        "common.more": "更多",
        "common.less": "收起",
        "common.empty": "暂无数据",
        "common.retry": "重试",
        "common.networkError": "网络错误",
        "common.serverError": "服务器错误",
        "common.unknownError": "未知错误"
    ]
    
    static let english: [String: String] = [
        // App
        "app.name": "AI Attendance System",
        "app.slogan": "Smart Check-in, Efficient Management",
        
        // Language Selection
        "language.select": "请选择语言 / Please Select Language",
        "language.chinese": "中文",
        "language.english": "English",
        "language.continue": "Continue",
        
        // Login
        "login.welcome": "Welcome",
        "login.employeeId": "Enter Employee ID",
        "login.password": "Enter Password",
        "login.button": "Login",
        "login.faceLogin": "Face Recognition Login",
        "login.firstTime": "First time users please use employee ID and initial password",
        "login.forgotPassword": "Contact admin if you forgot password",
        "login.failed": "Login Failed",
        "login.errorMessage": "Invalid employee ID or password",
        
        // Tabs
        "tab.attendance": "Check-in",
        "tab.records": "Records",
        "tab.statistics": "Statistics",
        "tab.profile": "Profile",
        "tab.dashboard": "Dashboard",
        "tab.employees": "Employees",
        "tab.approval": "Approval",
        "tab.settings": "Settings",
        "tab.aiChat": "AI Assistant",
        
        // Attendance
        "attendance.title": "AI Check-in",
        "attendance.currentUser": "Current User",
        "attendance.admin": "Admin",
        "attendance.employee": "Employee",
        "attendance.checkIn": "Check In",
        "attendance.checkOut": "Check Out",
        "attendance.workTime": "Work Time",
        "attendance.offTime": "Off Time",
        "attendance.workDuration": "Work Duration",
        "attendance.photoVerified": "Photo Check-in",
        "attendance.selectMethod": "Select Check-in Method",
        "attendance.normalCheckIn": "Normal Check-in",
        "attendance.photoCheckIn": "Photo Check-in",
        "attendance.cancel": "Cancel",
        "attendance.faceToCamera": "Please face the camera for photo",
        "attendance.startCheckIn": "Start Check-in",
        
        // Records
        "records.title": "Check-in Records",
        "records.today": "Today",
        "records.thisWeek": "This Week",
        "records.thisMonth": "This Month",
        "records.lastMonth": "Last Month",
        "records.custom": "Custom",
        "records.noRecords": "No Records",
        "records.noRecordsDesc": "No check-in records for this period",
        "records.normal": "Normal",
        "records.late": "Late",
        "records.checkInRecord": "Check In",
        "records.checkOutRecord": "Check Out",
        "records.workHours": "%.1f hours worked",
        
        // Statistics
        "statistics.title": "Statistics",
        "statistics.monthlyOverview": "Monthly Overview",
        "statistics.shouldAttend": "Should Attend",
        "statistics.actualAttend": "Actual Attend",
        "statistics.attendanceRate": "Attendance Rate",
        "statistics.normalAttend": "Normal Attendance",
        "statistics.completeDays": "Complete Workdays",
        "statistics.late": "Late",
        "statistics.earlyLeave": "Early Leave",
        "statistics.absent": "Absent",
        "statistics.leave": "Leave",
        "statistics.overtime": "Overtime",
        "statistics.photoCheckIn": "Photo Check-in",
        "statistics.verified": "Verified",
        "statistics.verificationRate": "Verification Rate",
        "statistics.workHourStats": "Work Hour Statistics",
        "statistics.dailyAverage": "Daily Average",
        "statistics.totalHours": "Total Hours",
        
        // Profile
        "profile.title": "Profile",
        "profile.personalInfo": "Personal Info",
        "profile.faceManagement": "Face Management",
        "profile.notifications": "Notifications",
        "profile.leaveApplication": "Leave Application",
        "profile.makeupApplication": "Makeup Application",
        "profile.myApplications": "My Applications",
        "profile.settings": "Settings",
        "profile.help": "Help & Feedback",
        "profile.logout": "Logout",
        "profile.confirmLogout": "Are you sure you want to logout?",
        "profile.version": "Version",
        "profile.developer": "Developer",
        "profile.developerName": "AI Attendance Team",
        
        // Admin Dashboard
        "dashboard.title": "Dashboard",
        "dashboard.realTimeData": "Today's Real-time Data",
        "dashboard.checkedIn": "Checked In",
        "dashboard.checkInRate": "Check-in Rate",
        "dashboard.departmentOverview": "Department Overview",
        "dashboard.pendingTasks": "Pending Tasks",
        "dashboard.pendingLeave": "Pending Leave",
        "dashboard.pendingMakeup": "Pending Makeup",
        "dashboard.attendanceTrend": "Today's Check-in Distribution",
        "dashboard.abnormalAttendance": "Abnormal Attendance",
        "dashboard.viewAll": "View All",
        "dashboard.techDept": "Tech Dept",
        "dashboard.marketDept": "Marketing",
        "dashboard.adminDept": "Admin Dept",
        "dashboard.financeDept": "Finance",
        "dashboard.hrDept": "HR Dept",
        
        // Employee Management
        "employee.title": "Employee Management",
        "employee.search": "Search by name or ID",
        "employee.total": "Total %d employees",
        "employee.add": "Add Employee",
        "employee.notFound": "No employees found",
        "employee.adjustSearch": "Try adjusting search criteria",
        "employee.basicInfo": "Basic Information",
        "employee.name": "Name",
        "employee.id": "Employee ID",
        "employee.department": "Department",
        "employee.position": "Position",
        "employee.accountSettings": "Account Settings",
        "employee.initialPassword": "Initial Password",
        "employee.sendWelcomeEmail": "Send Welcome Email",
        "employee.save": "Save",
        "employee.edit": "Edit Info",
        "employee.viewRecords": "View Records",
        "employee.resetPassword": "Reset Password",
        "employee.delete": "Delete Employee",
        "employee.people": "people",
        
        // Approval Center
        "approval.title": "Approval Center",
        "approval.pending": "Pending",
        "approval.approved": "Approved",
        "approval.all": "All",
        "approval.noPending": "No Pending Items",
        "approval.noPendingDesc": "All applications have been processed",
        "approval.noApproved": "No Approved Records",
        "approval.noApprovedDesc": "Approved records will appear here",
        "approval.leaveRequest": "Leave Request",
        "approval.makeupRequest": "Makeup Request",
        "approval.overtimeRequest": "Overtime Request",
        "approval.businessTrip": "Business Trip",
        "approval.approve": "Approve",
        "approval.reject": "Reject",
        "approval.rejectReason": "Rejection Reason",
        "approval.confirmReject": "Confirm Reject",
        "approval.applicationType": "Application Type",
        "approval.startTime": "Start Time",
        "approval.endTime": "End Time",
        "approval.reason": "Reason",
        "approval.submitTime": "Submit Time",
        "approval.approvalTime": "Approval Time",
        "approval.status.pending": "Pending",
        "approval.status.approved": "Approved",
        "approval.status.rejected": "Rejected",
        
        // Leave Application
        "leave.title": "Leave Application",
        "leave.type": "Leave Type",
        "leave.personal": "Personal Leave",
        "leave.sick": "Sick Leave",
        "leave.annual": "Annual Leave",
        "leave.compensatory": "Compensatory Leave",
        "leave.startTime": "Start Time",
        "leave.endTime": "End Time",
        "leave.duration": "Leave Duration",
        "leave.reason": "Reason",
        "leave.reasonPlaceholder": "Enter reason for leave...",
        "leave.approver": "Approver",
        "leave.submit": "Submit Application",
        "leave.submitSuccess": "Submitted Successfully",
        "leave.submitSuccessDesc": "Your leave application has been submitted, please wait for approval",
        "leave.confirm": "OK",
        
        // Makeup Application
        "makeup.title": "Makeup Application",
        "makeup.date": "Makeup Date",
        "makeup.type": "Makeup Type",
        "makeup.checkIn": "Check-in Makeup",
        "makeup.checkOut": "Check-out Makeup",
        "makeup.both": "Full Day Makeup",
        "makeup.time": "Makeup Time",
        "makeup.reason": "Reason",
        "makeup.reasonPlaceholder": "Enter reason for makeup...",
        "makeup.quickSelect": "Quick Select",
        "makeup.systemError": "System error, unable to check in",
        "makeup.forgot": "Forgot to check in",
        "makeup.networkIssue": "Network issue, check-in failed",
        "makeup.other": "Other",
        "makeup.evidence": "Evidence",
        "makeup.addPhoto": "Add Photo Evidence (Optional)",
        "makeup.submit": "Submit Application",
        "makeup.submitSuccess": "Submitted Successfully",
        "makeup.submitSuccessDesc": "Your makeup application has been submitted, please wait for approval",
        
        // Settings
        "settings.title": "Settings",
        "settings.workTime": "Work Hours",
        "settings.startTime": "Start Time",
        "settings.endTime": "End Time",
        "settings.features": "Feature Settings",
        "settings.enablePhoto": "Enable Photo Check-in",
        "settings.enableNotifications": "Enable Notifications",
        "settings.defaultLocation": "Default Location",
        "settings.inputLocation": "Enter location",
        "settings.dataManagement": "Data Management",
        "settings.exportData": "Export Data",
        "settings.clearData": "Clear All Data",
        "settings.clearDataWarning": "This will delete all check-in records and cannot be undone.",
        "settings.about": "About",
        "settings.adminFeatures": "Admin Features",
        "settings.userManagement": "User Management",
        "settings.systemSettings": "System Settings",
        "settings.auditLog": "Audit Log",
        "settings.attendanceRules": "Attendance Rules",
        "settings.basicSettings": "Basic Settings",
        "settings.lateToleranceMinutes": "Late Tolerance (minutes)",
        "settings.aiSettings": "AI Recognition Settings",
        "settings.enableLivenessDetection": "Enable Liveness Detection",
        "settings.recognitionAccuracy": "Recognition Accuracy",
        "settings.high": "High",
        "settings.medium": "Medium",
        "settings.low": "Low",
        "settings.allowMaskRecognition": "Allow Mask Recognition",
        "settings.saveSettings": "Save Settings",
        
        // Common
        "common.ok": "OK",
        "common.cancel": "Cancel",
        "common.save": "Save",
        "common.delete": "Delete",
        "common.edit": "Edit",
        "common.submit": "Submit",
        "common.confirm": "Confirm",
        "common.back": "Back",
        "common.close": "Close",
        "common.loading": "Loading...",
        "common.error": "Error",
        "common.success": "Success",
        "common.warning": "Warning",
        "common.info": "Info",
        "common.all": "All",
        "common.none": "None",
        "common.select": "Select",
        "common.selected": "Selected",
        "common.unselected": "Unselected",
        "common.search": "Search",
        "common.filter": "Filter",
        "common.sort": "Sort",
        "common.refresh": "Refresh",
        "common.more": "More",
        "common.less": "Less",
        "common.empty": "No Data",
        "common.retry": "Retry",
        "common.networkError": "Network Error",
        "common.serverError": "Server Error",
        "common.unknownError": "Unknown Error"
    ]
}

// 便捷的本地化视图修饰符
struct LocalizedText: ViewModifier {
    @ObservedObject private var languageService = LanguageService.shared
    let key: String
    
    func body(content: Content) -> some View {
        Text(key.localized())
    }
}

extension View {
    func localizedText(_ key: String) -> Text {
        Text(key.localized())
    }
}