//
//  ContentView.swift
//  RemoveBackground
//
//  Created by i on 2025/9/6.
//

import SwiftUI
import PhotosUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation

class ImageSaver: NSObject {
    var onComplete: ((String) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage, format: SaveFormat) {
        let imageData: Data?
        
        switch format {
        case .jpg:
            imageData = image.jpegData(compressionQuality: 0.9)
        case .png:
            imageData = image.pngData()
        case .webp:
            // WebP需要使用Core Image
            if let ciImage = CIImage(image: image) {
                let context = CIContext()
                imageData = context.heifRepresentation(of: ciImage, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
            } else {
                imageData = image.pngData() // 备用PNG格式
            }
        }
        
        guard let data = imageData,
              let finalImage = UIImage(data: data) else {
            onComplete?("图片格式转换失败")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(finalImage, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            onComplete?("保存失败: \(error.localizedDescription)")
        } else {
            onComplete?("图片已保存到相册")
        }
    }
}

enum SaveFormat: String, CaseIterable {
    case jpg = "JPG"
    case png = "PNG"
    case webp = "WebP"
    
    var displayName: String {
        return self.rawValue
    }
}

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var isProcessing = false
    @State private var showingImagePicker = false
    @State private var dragOffset: CGFloat = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var imageSaver = ImageSaver()
    @State private var selectedFormat: SaveFormat = .png
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // 格式选择器 - 放在最上面
                VStack(alignment: .leading, spacing: 8) {
                    Text("保存格式")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("保存格式", selection: $selectedFormat) {
                        Text("JPG").tag(SaveFormat.jpg)
                        Text("PNG").tag(SaveFormat.png)
                        Text("WebP").tag(SaveFormat.webp)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                if let selectedImage = selectedImage {
                    // 图片对比视图
                    ComparisonView(
                        originalImage: selectedImage,
                        processedImage: processedImage,
                        dragOffset: $dragOffset
                    )
                    .frame(height: 400)
                    .clipped()
                    
                    // 控制按钮 - 保留选择图片选项
                    HStack(spacing: 8) {
                        Button(action: { showingImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo")
                                Text("选择图片")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        
                        Button(action: processImage) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "scissors")
                                }
                                Text(isProcessing ? "处理中..." : "去除背景")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(isProcessing ? Color.gray : Color.green)
                            .cornerRadius(10)
                        }
                        .disabled(isProcessing)
                        
                        if processedImage != nil {
                            Button(action: saveProcessedImage) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("保存")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                } else {
                    // 选择图片界面
                    VStack(spacing: 30) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("选择一张图片开始")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Button(action: { showingImagePicker = true }) {
                            Text("选择图片")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("背景去除")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage) {
                    processedImage = nil
                    dragOffset = 0
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func processImage() {
        guard let selectedImage = selectedImage else { return }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let processedImg = BackgroundRemover.removeBackground(from: selectedImage)
            
            DispatchQueue.main.async {
                self.processedImage = processedImg
                self.isProcessing = false
            }
        }
    }
    
    private func saveProcessedImage() {
        guard let processedImage = processedImage else { return }
        
        imageSaver.onComplete = { message in
            DispatchQueue.main.async {
                self.alertMessage = message
                self.showingAlert = true
            }
        }
        imageSaver.writeToPhotoAlbum(image: processedImage, format: selectedFormat)
    }
}

#Preview {
    ContentView()
}
