//
//  Window.swift
//  Client
//
//  Created by Eric Russell on 4/10/22.
//

import SwiftUI

struct Window<Content: View>: View {
    let content: () -> Content
    
    let title: String?
    @State private var position: CGPoint
    @State private var adjustedSize: CGSize
    @State private var adjustedPosition: CGPoint
    
    @Binding var size: CGSize
    
    @State private var expanded = false
    
    let foregroundColor = Color.white
    
    init(title: String? = nil, position: CGPoint, size: Binding<CGSize>, content: @escaping ()->Content) {
        self.content = content
        self.title = title
        self.position = position
        self.adjustedSize = CGSize.zero
        self.adjustedPosition = CGPoint.zero
        self._size = size
    }
    
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Color.gray
                    ZStack(alignment: .center) {
                        Text(title ?? " ")
                        .padding(.horizontal, 0)
                        .font(.title3)
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
                .frame(width: self.adjustedSize.width, height: 40)

                if self.expanded {
                    ZStack {
                        VStack(content: self.content)
                        .padding(.vertical,0)
                        .frame(width: self.size.width,
                               height:
                                self.expanded ? self.adjustedSize.height : 0)
                        .background(.ultraThinMaterial)
                        .preferredColorScheme(.light)
                    }
                }
            }
            .onChange(of: gp.size) { size in
                let size = CGSize(width: size.width, height: size.height)
                self.adjustedSize = adjustSize(newSize: self.size)
                self.adjustedPosition = self.adjustPosition(newSize: size)
            }
            .onChange(of: self.size) { size in
                let size = CGSize(width: size.width, height: size.height)
                self.adjustedSize = adjustSize(newSize: size)
                self.adjustedPosition = self.adjustPosition(newSize: gp.size)
            }
            .onAppear {
                let size = CGSize(width: size.width, height: size.height)
                self.adjustedSize = adjustSize(newSize: size)
                self.adjustedPosition = self.adjustPosition(newSize: gp.size)
            }
            .padding(.leading, self.adjustedPosition.x)
            .padding(.top, self.position.y < 0 ? -self.position.y : self.position.y)
            .padding(.bottom, 0)
        }
    }
    
    private func adjustPosition(newSize: CGSize) -> CGPoint {
        return CGPoint(
            x: self.position.x < 0 ? newSize.width + self.position.x : self.position.x,
            y: self.position.y
        )
    }
    
    func adjustSize(newSize: CGSize) -> CGSize {
        print("adjusting size")
        return CGSize(
            width: self.size.width <= 1.0 ? newSize.width * self.size.width : self.size.width,
            height: self.size.height <= 1.0 ? newSize.height * self.size.height :
                self.size.height
            )
    }
}

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        Window(title: "Preview", position: CGPoint(x: 50, y: 100), size: Binding.constant(CGSize(width: 400, height: 400))) {
            Color.blue
        }
    }
}
