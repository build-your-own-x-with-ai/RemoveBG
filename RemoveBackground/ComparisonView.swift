import SwiftUI

struct CheckerboardBackground: View {
    var body: some View {
        Canvas { context, size in
            let squareSize: CGFloat = 15
            let rows = Int(size.height / squareSize) + 1
            let cols = Int(size.width / squareSize) + 1
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let isEven = (row + col) % 2 == 0
                    let color = isEven ? Color.white : Color.gray.opacity(0.2)
                    
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
    }
}

struct ComparisonView: View {
    let originalImage: UIImage
    let processedImage: UIImage?
    @Binding var dragOffset: CGFloat
    
    @State private var viewWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 整体背景
                Rectangle()
                    .fill(Color.black.opacity(0.05))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 右侧显示原图
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .mask(
                        Rectangle()
                            .frame(width: max(0, geometry.size.width - ((geometry.size.width / 2) + dragOffset)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    )
                
                // 左侧棋盘格背景（仅在左侧显示）
                CheckerboardBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .mask(
                        Rectangle()
                            .frame(width: max(0, (geometry.size.width / 2) + dragOffset))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    )
                
                // 左侧显示处理后的透明背景图片
                if let processedImage = processedImage {
                    Image(uiImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .mask(
                            Rectangle()
                                .frame(width: max(0, (geometry.size.width / 2) + dragOffset))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        )
                }
                
                // 分割线 - 更现代的设计
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4)
                    .shadow(color: .black.opacity(0.2), radius: 4)
                    .offset(x: dragOffset)
                
                // 拖动手柄 - 更现代的设计
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.15), radius: 8)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray.opacity(0.8))
                }
                .offset(x: dragOffset)
            }
            .onAppear {
                viewWidth = geometry.size.width
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                viewWidth = newWidth
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = value.translation.width
                        let maxOffset = viewWidth / 2
                        dragOffset = max(-maxOffset, min(maxOffset, newOffset))
                    }
            )
        }
        .overlay(
            VStack {
                HStack {
                    // 左侧标签
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text("透明背景")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    )
                    
                    Spacer()
                    
                    // 右侧标签
                    if processedImage != nil {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                            Text("原图")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 4)
                        )
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        )
    }
}