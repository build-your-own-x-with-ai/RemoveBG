import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}

class BackgroundRemover {
    static func removeBackground(from image: UIImage) -> UIImage? {
        // 首先将图片标准化为.up方向，这样处理后不会有旋转问题
        let normalizedImage = normalizeImageOrientation(image)
        
        guard let cgImage = normalizedImage.cgImage else { return nil }
        
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        // 使用标准化后的图片，方向始终为.up
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let result = request.results?.first else { return nil }
            
            let maskPixelBuffer = result.pixelBuffer
            let originalImage = CIImage(cgImage: cgImage)
            let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
            
            // 创建CIContext
            let context = CIContext()
            
            // 使用CIBlendWithMask滤镜来正确处理透明背景
            guard let blendFilter = CIFilter(name: "CIBlendWithMask") else { 
                return fallbackRemoveBackground(originalImage: originalImage, maskImage: maskImage, context: context, originalUIImage: normalizedImage)
            }
            
            // 确保mask图像与原图尺寸一致
            let scaledMaskImage = maskImage.transformed(by: CGAffineTransform(scaleX: originalImage.extent.width / maskImage.extent.width, 
                                                                            y: originalImage.extent.height / maskImage.extent.height))
            
            // 创建透明背景，确保尺寸与原图一致
            let transparentBackground = CIImage(color: CIColor.clear).cropped(to: originalImage.extent)
            
            // 设置滤镜参数
            blendFilter.setValue(originalImage, forKey: kCIInputImageKey)        // 前景（原图）
            blendFilter.setValue(transparentBackground, forKey: kCIInputBackgroundImageKey) // 背景（透明）
            blendFilter.setValue(scaledMaskImage, forKey: kCIInputMaskImageKey)  // 遮罩（缩放到原图尺寸）
            
            // 获取输出图像
            guard let outputImage = blendFilter.outputImage else {
                return fallbackRemoveBackground(originalImage: originalImage, maskImage: maskImage, context: context, originalUIImage: normalizedImage)
            }
            
            // 确保输出图像尺寸与原图一致
            let finalImage = outputImage.cropped(to: originalImage.extent)
            
            // 转换为CGImage然后转为UIImage，保持标准化的方向
            guard let cgOutputImage = context.createCGImage(finalImage, from: finalImage.extent) else {
                return fallbackRemoveBackground(originalImage: originalImage, maskImage: maskImage, context: context, originalUIImage: normalizedImage)
            }
            
            // 返回标准化方向的图片，这样就不会有旋转问题
            return UIImage(cgImage: cgOutputImage, scale: image.scale, orientation: .up)
            
        } catch {
            print("背景去除失败: \(error)")
            return nil
        }
    }
    
    // 标准化图片方向，将所有图片转换为.up方向
    private static func normalizeImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? image
    }
    
    // 备用方法：手动处理像素
    private static func fallbackRemoveBackground(originalImage: CIImage, maskImage: CIImage, context: CIContext, originalUIImage: UIImage) -> UIImage? {
        let width = Int(originalImage.extent.width)
        let height = Int(originalImage.extent.height)
        
        // 创建原图的CGImage
        guard let originalCGImage = context.createCGImage(originalImage, from: originalImage.extent) else { return nil }
        
        // 确保mask图像与原图尺寸一致
        let scaledMaskImage = maskImage.transformed(by: CGAffineTransform(scaleX: originalImage.extent.width / maskImage.extent.width, 
                                                                        y: originalImage.extent.height / maskImage.extent.height))
        
        // 创建mask的CGImage
        guard let maskCGImage = context.createCGImage(scaledMaskImage, from: scaledMaskImage.extent) else { return nil }
        
        // 创建带alpha通道的位图上下文
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let bitmapContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        
        // 获取原图像素数据
        guard let originalData = originalCGImage.dataProvider?.data,
              let originalBytes = CFDataGetBytePtr(originalData) else { return nil }
        
        // 获取mask像素数据
        guard let maskData = maskCGImage.dataProvider?.data,
              let maskBytes = CFDataGetBytePtr(maskData) else { return nil }
        
        // 获取输出位图数据
        guard let outputData = bitmapContext.data?.assumingMemoryBound(to: UInt8.self) else { return nil }
        
        // 处理每个像素
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                let outputIndex = pixelIndex * 4
                let originalIndex = pixelIndex * 4 // 假设原图也是RGBA
                
                // 获取mask值（0-255）
                let maskValue = maskBytes[pixelIndex]
                let alpha = Float(maskValue) / 255.0
                
                // 如果原图是RGB，需要调整索引
                let originalBytesPerPixel = originalCGImage.bitsPerPixel / 8
                let originalPixelIndex = pixelIndex * originalBytesPerPixel
                
                if originalBytesPerPixel == 3 { // RGB
                    outputData[outputIndex] = originalBytes[originalPixelIndex]     // R
                    outputData[outputIndex + 1] = originalBytes[originalPixelIndex + 1] // G
                    outputData[outputIndex + 2] = originalBytes[originalPixelIndex + 2] // B
                } else { // RGBA
                    outputData[outputIndex] = originalBytes[originalIndex]     // R
                    outputData[outputIndex + 1] = originalBytes[originalIndex + 1] // G
                    outputData[outputIndex + 2] = originalBytes[originalIndex + 2] // B
                }
                
                // 设置alpha值
                outputData[outputIndex + 3] = UInt8(alpha * 255)
            }
        }
        
        // 创建CGImage
        guard let outputCGImage = bitmapContext.makeImage() else { return nil }
        
        // 返回标准化方向的图片
        return UIImage(cgImage: outputCGImage, scale: originalUIImage.scale, orientation: .up)
    }
}