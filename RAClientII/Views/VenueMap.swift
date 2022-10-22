//
//  VenueMap.swift
//  RAClientII
//
//  Created by Eric Russell on 10/20/22.
//

import SwiftUI
import SpriteKit

struct VenueMap: View {
    @EnvironmentObject var scene: GameScene
    
    @State private var lastDragLocation: CGPoint?
   
    var body: some View {
        GeometryReader { gp in
            ZStack {
                SpriteView(scene: scene)
                    .background(Color.cyan)
                .frame(width: gp.size.width, height: gp.size.height, alignment: .topLeading)
            }
        }
    }
    
    func dragChanged(value: DragGesture.Value) {
        if lastDragLocation != nil {
            let delta = CGPoint(
                x: value.location.x - lastDragLocation!.x,
                y: value.location.y - lastDragLocation!.y
            )
            
            scene.camera?.position.x -= delta.x
            scene.camera?.position.y -= delta.y
        }
        
        self.lastDragLocation = value.location
    }
}

struct VenueMap_Previews: PreviewProvider {
    static var previews: some View {
        VenueMap()
    }
}
