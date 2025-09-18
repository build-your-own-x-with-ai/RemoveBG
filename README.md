# 背景去除应用

[![GitHub](https://img.shields.io/badge/GitHub-buld--your--own--x--with--ai%2FRemoveBG-blue?logo=github)](https://github.com/buld-your-own-x-with-ai/RemoveBG)
[![iOS](https://img.shields.io/badge/iOS-18.5%2B-blue?logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0%2B-orange?logo=swift)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green?logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![Vision](https://img.shields.io/badge/Vision-Framework-purple?logo=apple)](https://developer.apple.com/documentation/vision)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/buld-your-own-x-with-ai/RemoveBG/pulls)

这是一个使用SwiftUI开发的iOS应用，可以智能去除图片背景并提供多种功能。

## 🔗 项目地址

**GitHub仓库**: [https://github.com/buld-your-own-x-with-ai/RemoveBG](https://github.com/buld-your-own-x-with-ai/RemoveBG)



## ✨ 主要功能

### 🎯 智能背景去除
- 使用苹果Vision框架的人像分割技术
- 高精度识别并保留人物主体
- 背景完全透明化处理
- 支持各种复杂背景场景

### 📱 现代化界面设计
- **SegmentedControl格式选择器**：位于界面顶部，支持JPG、PNG、WebP三种保存格式
- **左右对比功能**：可拖动分割线实时对比原图和去背景效果
- **棋盘格背景**：清晰显示透明区域效果
- **流畅交互体验**：现代化渐变分割线和精美拖动手柄

### 💾 多格式保存支持
- **PNG格式**：保持完整透明背景，最佳选择
- **JPG格式**：适合不需要透明背景的场景，文件更小
- **WebP格式**：现代化格式，文件小且支持透明

## 📸 应用截图
![应用主界面](screenshots/main-interface.jpg)
*主界面展示格式选择器和对比功能*
![原图](screenshots/soccer.webp)
*原图*
![保存](screenshots/soccer.jpg)
*去背景*

### 🔧 技术特性
- **图片方向修复**：彻底解决旋转90度问题，输出图片与原图方向完全一致
- **尺寸保持**：处理后图片与原图尺寸完全一致
- **高质量处理**：使用Core Image和Vision框架确保最佳效果
- **异步处理**：后台处理不阻塞UI，提供流畅用户体验

## 📦 安装和运行

### 克隆项目
```bash
git clone https://github.com/build-your-own-x-with-ai/RemoveBG.git
cd RemoveBG
```

### 在Xcode中运行
1. 使用Xcode 16.0+打开`RemoveBackground.xcodeproj`
2. 选择目标设备（iPhone模拟器或真机）
3. 点击运行按钮或按`Cmd+R`

### 系统要求
- macOS 15.0+ (用于开发)
- Xcode 16.0+
- iOS 18.5+ (目标设备)

## 🚀 使用方法

1. **选择保存格式**：在顶部SegmentedControl中选择JPG/PNG/WebP
2. **选择图片**：点击"选择图片"从相册选择照片
3. **去除背景**：点击"去除背景"开始智能处理
4. **对比效果**：左右拖动分割线查看原图与透明背景的对比
5. **保存图片**：点击"保存"按钮，使用选定格式保存到相册

## 🛠 技术实现

### 核心技术栈
- **SwiftUI**：现代化响应式用户界面框架
- **Vision框架**：苹果官方机器学习人像分割API
- **Core Image**：高性能图像处理和滤镜应用
- **PhotosUI**：相册访问和图片选择
- **Canvas**：自定义棋盘格背景绘制

### 关键算法
- **VNGeneratePersonSegmentationRequest**：高精度人像分割
- **CIBlendWithMask**：透明背景合成
- **图片标准化处理**：解决方向旋转问题
- **像素级处理**：备用算法确保兼容性

### 权限配置
- 通过Build Settings配置权限（不使用Info.plist）
- 相册访问权限：`INFOPLIST_KEY_NSPhotoLibraryUsageDescription`
- 相机访问权限：`INFOPLIST_KEY_NSCameraUsageDescription`

## 📁 项目结构

```
RemoveBackground/
├── RemoveBackground/
│   ├── RemoveBackgroundApp.swift      # 应用入口
│   ├── ContentView.swift              # 主界面
│   ├── ComparisonView.swift           # 对比视图组件
│   ├── ImagePicker.swift              # 图片选择器
│   ├── BackgroundRemover.swift        # 背景去除核心逻辑
│   └── Assets.xcassets/               # 应用资源
├── RemoveBackground.xcodeproj/        # Xcode项目文件
└── README.md                          # 项目说明
```

## 📋 系统要求

### 开发环境
- macOS 15.0+
- Xcode 16.0+
- Swift 5.0+

### 运行环境
- iOS 18.5+
- 支持iPhone和iPad
- 需要相册访问权限

## 🎨 界面预览

### 主要界面元素
- **格式选择器**：顶部SegmentedControl，直观选择保存格式
- **图片对比区域**：左侧透明背景，右侧原图，可拖动分割线
- **控制按钮**：选择图片、去除背景、保存图片
- **状态指示**：处理进度和结果提示

### 视觉设计
- 现代化扁平设计风格
- 渐变色彩搭配
- 流畅动画效果
- 响应式布局适配

## 🔍 技术亮点

### 1. 智能背景分割
```swift
let request = VNGeneratePersonSegmentationRequest()
request.qualityLevel = .accurate
request.outputPixelFormat = kCVPixelFormatType_OneComponent8
```

### 2. 透明背景合成
```swift
let blendFilter = CIFilter(name: "CIBlendWithMask")
blendFilter.setValue(originalImage, forKey: kCIInputImageKey)
blendFilter.setValue(transparentBackground, forKey: kCIInputBackgroundImageKey)
blendFilter.setValue(scaledMaskImage, forKey: kCIInputMaskImageKey)
```

### 3. 图片方向标准化
```swift
private static func normalizeImageOrientation(_ image: UIImage) -> UIImage {
    if image.imageOrientation == .up { return image }
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return normalizedImage ?? image
}
```

## 📝 更新日志

### v1.0.0 (2025/9/6)
- ✅ 实现智能背景去除功能
- ✅ 添加左右拖动对比界面
- ✅ 支持多种保存格式（JPG/PNG/WebP）
- ✅ 修复图片旋转90度问题
- ✅ 优化图片尺寸处理
- ✅ 添加SegmentedControl格式选择器
- ✅ 移除录制功能，简化界面
- ✅ 完善权限配置和错误处理

## 🤝 贡献

我们欢迎所有形式的贡献！

### 如何贡献
1. Fork这个仓库
2. 创建你的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个Pull Request

### 报告问题
如果你发现了bug或有功能建议，请在[GitHub Issues](https://github.com/buld-your-own-x-with-ai/RemoveBG/issues)中提交。

### 开发指南
- 遵循Swift编码规范
- 确保代码通过编译测试
- 添加适当的注释和文档
- 保持代码简洁和可读性

## 📄 许可证

MIT License

---

**享受智能背景去除的便捷体验！** 🎉
