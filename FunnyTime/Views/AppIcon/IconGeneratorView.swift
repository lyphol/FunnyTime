import SwiftUI
import UIKit

struct IconGeneratorView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("App 图标生成器")
                .font(.title)
            
            // 预览区域
            VStack(spacing: 20) {
                AppIconPreview(isDark: false)
                    .frame(width: 200, height: 200)
                AppIconPreview(isDark: true)
                    .frame(width: 200, height: 200)
            }
            
            // 生成按钮
            Button("生成所有尺寸图标") {
                generateIcons()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func generateIcons() {
        do {
            let urls = try AppIconGenerator.generateIcons()
            alertMessage = """
                图标已生成到桌面的 FunnyTimeIcons 文件夹中
                路径：\(urls.first?.deletingLastPathComponent().path ?? "")
                
                请在 Finder 中查看生成的图标文件。
                """
            showingAlert = true
        } catch {
            alertMessage = "生成失败：\(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    IconGeneratorView()
} 