# AI上班打卡系统

## 项目配置

在运行项目前，请在Xcode中进行以下配置：

### 1. 添加Info.plist权限描述

在Xcode中：
1. 选择项目导航器中的项目文件
2. 选择目标(Target) -> Info
3. 添加以下权限描述：

- **Privacy - Camera Usage Description**: AI打卡系统需要使用相机进行人脸验证打卡
- **Privacy - Location When In Use Usage Description**: AI打卡系统需要获取您的位置信息以记录打卡地点
- **Privacy - Photo Library Usage Description**: AI打卡系统需要访问相册以保存打卡截图

### 2. 项目结构

```
AI上班打卡系统/
├── Core/                    # 核心模块
│   ├── Models/             # 数据模型
│   ├── Services/           # 通用服务
│   └── Extensions/         # 扩展
├── Modules/                # 功能模块
│   ├── Attendance/         # 打卡模块
│   ├── AICamera/          # AI相机模块
│   ├── Statistics/        # 统计模块
│   └── Settings/          # 设置模块
└── MainTabView.swift      # 主界面
```

### 3. 功能特性

- ✅ 上下班打卡
- ✅ AI人脸识别验证
- ✅ 位置记录
- ✅ 考勤统计分析
- ✅ 数据导出
- ✅ 个性化设置

### 4. 技术栈

- SwiftUI
- SwiftData
- Vision Framework
- CoreLocation
- AVFoundation
- Charts

### 5. 运行要求

- iOS 17.0+
- Xcode 15.0+
- 真机测试（相机功能需要真机）