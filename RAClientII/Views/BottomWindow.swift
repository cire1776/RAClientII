//
//  BottomWindow.swift
//  Client
//
//  Created by Eric Russell on 4/10/22.
//

import SwiftUI

struct BottomWindow<Content: View>: View {
    let content: () -> Content
    
    let title: String?
    let height: CGFloat
    
    @State private var expanded = false
    
    let foregroundColor = Color.white
    
    init(title: String? = nil, height: CGFloat, content: @escaping () -> Content) {
        self.content = content
        self.title = title
        self.height = height
    }

    var body: some View {
        GeometryReader { gp in
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    Color.gray
                    VStack(spacing: 0) {
                        ZStack(alignment: .center) {
                            Text(title ?? " ")
                            .padding(.horizontal, 0)
                            .font(.caption2)
                            .foregroundColor(self.foregroundColor)
                            HStack {
                                Spacer()
                                Image(systemName: self.expanded ? "chevron.down" : "chevron.right")
                                    .font(.caption)
                                    .padding(.trailing, 15)
                                    .foregroundColor(self.foregroundColor)
                                    .onTapGesture {
                                        self.expanded.toggle()
                                    }
                            }
                        }
                    }
                }
                .frame(height: 40)

                if expanded {
                    VStack(content: self.content)
                        .frame(width: gp.size.width, height: self.expanded ? self.height : 0)
                    .background(.ultraThinMaterial)
                    .preferredColorScheme(.light)
                }
            }
            .padding(.vertical, 0)
            .preference(key: MainView.ContentSizePreferenceKey.self,
                        value: CGSize(width: gp.size.width, height: self.expanded ? self.height + 40 : 40))
        }
    }
}

struct BottomWindow_Previews: PreviewProvider {
    static var previews: some View {
        BottomWindow(title: "Preview", height: 350) {
            Color.green
        }
    }
}
