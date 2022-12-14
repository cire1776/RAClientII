//
//  HexagonMapNode.swift
//  OldRAClient
//
//  Created by Eric Russell on 4/22/22.
//

import SpriteKit
import OrderedCollections
import Combine

class HexagonMapNode: SKNode, EntityHolder {
    static func setup(scene: GameScene, radius: CGFloat) {
        let hexagonMapNode = HexagonMapNode(in: scene.venue,of: radius, orientation: scene.orientation)
        
        scene.addChild(hexagonMapNode)
        scene.hexagonMapNode = hexagonMapNode
        
        let edges = scene.venue.region.collectEdges(using: scene.orientation.topology(radius: radius))

        hexagonMapNode.createShadow(from: edges) { node in
            node.lineWidth = 20
            node.strokeColor = .lightGray
            
            let effect : SKEffectNode = SKEffectNode()
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(5, forKey: "inputRadius")
            effect.filter = filter
            effect.addChild(node)
            effect.zPosition = Constants.backgroundEffectLevel
            
            return effect
        }
        
        let path = hexagonMapNode.createPath(from: edges,closed: true)
        let shapeNode = SKShapeNode(path: path)
        shapeNode.strokeColor = .black
        shapeNode.lineWidth = 2
        hexagonMapNode.addChild(shapeNode)
        
        hexagonMapNode.physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        
        hexagonMapNode.drawDroppedItems(newDroppedItems: scene.venue.droppedItems)
    }

    let venue: Venue
    let region: Hexagon.Region<Geography.TerrainSpecifier>
    let radius: CGFloat
    let orientation: Hexagon.Orientation
    var selection: Coordinates? = nil
    var facilityNodes = [Facility.ID : SKNode]()
    
    init(in venue: Venue, of radius: CGFloat,  orientation: Hexagon.Orientation) {
        self.venue = venue
        self.region = venue.region
        self.radius = radius
        self.orientation = orientation
        
        super.init()
        self.name = "HexagonMapNode"
        
        createHexagonNodes()
        createFacilityNodes()

        subscribe()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subscribe() {
        var cancellable = self.venue.$droppedItems.sink(receiveValue: { newItems in self.drawDroppedItems(newDroppedItems: newItems) })
        
        allSubscriptions.insert(cancellable)
        
        cancellable = self.venue.$facilities.sink(receiveValue:  { facilities in
            print("received subscription update for facilities")
            self.createFacilityNodes(facilities: facilities)
        })
        
        allSubscriptions.insert(cancellable)
    }
    
    func drawDroppedItems(newDroppedItems: [String : DroppedItem]) {
        print("**** received droppedItems subscription update")
        let holder = self.droppedItemsLayer
        
        holder.removeAllChildren()
        
        for (_, drop) in newDroppedItems {
            _ = DroppedItemNode(droppedItem: drop, holder: holder)
        }
    }
    
    private var droppedItemsLayer: HolderNode {
        let holder: HolderNode
        if let layer = self.childNode(withName: Constants.droppedItemLayerName) {
            layer.removeAllChildren()
            holder = layer as! HolderNode
        } else {
            holder = HolderNode()
            holder.name = Constants.droppedItemLayerName
            self.addChild(holder)
        }
        return holder
    }
    
    func select(coordinates: Coordinates) {
        if let selection = self.selection {
            let previouslySelectedNode = self.childNode(withName: Hexagon.nameFrom(coordinates: selection)) as! HexagonNode
            previouslySelectedNode.strokeColor = .white
            previouslySelectedNode.lineWidth = 2
            previouslySelectedNode.zPosition = Constants.hexagonTileLevel
            
        }
        
        if let selectedNode = self.childNode(withName: Hexagon.nameFrom(coordinates: coordinates)) as? HexagonNode {
            self.selection = coordinates

            selectedNode.strokeColor = .yellow
            selectedNode.lineWidth = 4
            selectedNode.zPosition = Constants.selectedHexagonTileLevel
        }
    }
    
    func createHexagonNodes() {
        region.ForEach { specifier, coordinates in
            let hex = MappedHexagon(Hexagon(orientation: orientation, terrain: specifier.terrain!, modifier: specifier.modifier), at: coordinates, of: radius)
            createHexagonNode(hex: hex, coordinates: coordinates)
        }
    }
    
    func createHexagonNode(hex: MappedHexagon, coordinates: (Int, Int)) {
        let radius = CGFloat(100)
        let node = HexagonNode(at: coordinates, hexagon: hex, radius: radius)
        
        let color: SKColor
        
        switch hex.hexagon.terrain {
        case .grassland:
            color = SKColor(red: 106/255, green: 171/255, blue: 142/255, alpha: 1.0)
        case .prairie:
            // pear: 209    226    49
            // olive: 128    128    0
            // apple green: 141    182    0
            // straw: 228    217    111
            color = SKColor(red: 228/255, green: 217/255, blue: 111/255, alpha: 1.0)
        case .desert:
            // Ivory: 255  255 240
            // biege 245 245 220
            // flavescent: 247    233    142
            color = SKColor(red: 240/255, green: 240/255 , blue: 171/255, alpha: 1.0)
        case .hills:
            // ochre: 204    119    34
            // chamoisee: 160    120    90
            color = SKColor(red: 160/255, green: 120/255 , blue: 90/255, alpha: 1.0)
        case .mountain:
            color = .gray
        default:
            color = .magenta
        }
        
        node.fillColor = color
        node.strokeColor = .white
        node.lineWidth = 2

        let origin = hex.topology.origin(at: coordinates)

        node.position = origin
        node.name = Hexagon.nameFrom(coordinates: coordinates)
        node.zPosition = Constants.hexagonTileLevel

//        let label = SKLabelNode(text: node.name)
//        label.position = .zero

        self.addChild(node)
//        node.addChild(label)
        
//        let centerAdorner = SKShapeNode(circleOfRadius: 5)
//        centerAdorner.position = origin
//        centerAdorner.fillColor = .red
//        self.addChild(centerAdorner)
    }
    
    private func createFacilityNodes(facilities: [Facility.ID : Facility]? = nil) {
        for (_, node) in self.facilityNodes {
            node.removeFromParent()
        }
        
        self.facilityNodes.removeAll()
        
//        for (_, facility) in facilities ?? self.venue.facilities {
//            // must be before tree
//            if let fruitTree = facility as? Facilities.FruitTree {
//                let facility = FruitTreeNode(facility: fruitTree, holder: self)
//                self.facilityNodes[fruitTree.id] = facility
//                continue
//            }
//
//            if let tree = facility as? Facilities.Tree {
//                let facility = TreeNode(facility: tree, holder: self)
//                self.facilityNodes[tree.id] = facility
//                continue
//            }
//
//            if let sawmill = facility as? Facilities.SawMill {
//                let facility = SawMillNode(facility: sawmill, holder: self)
//                self.facilityNodes[sawmill.id] = facility
//            }
//
//            if let rubblePile = facility as? Facilities.RubblePile {
//                let facility = RubblePileNode(facility: rubblePile, holder: self)
//                self.facilityNodes[rubblePile.id] = facility
//            }
//        }
    }
    
    func updateFacilityNode(for facility: Facility) {
        
//        if let tree = facility as? Facilities.Tree {
//            let facility = TreeNode(facility: tree, holder: self)
//            self.facilityNodes[tree.id] = facility
//        } else {
//            print("Unknown facility type")
//        }
    }
    
    func createDroppedItemNodes() {
        for (_, drop) in self.venue.droppedItems {
            createDroppedItemNode(for: drop)
        }
    }
    
    func createDroppedItemNode(for drop: DroppedItem) {
        _ = DroppedItemNode(droppedItem: drop, holder: self)
    }
    
    func createPath(from edges: OrderedSet<Hexagon.Edge>,closed: Bool = false) -> CGPath {
        let radius: CGFloat = 100
        var points = edges.map {
            orientation.topology(radius: radius).plot(for: $0, of: radius)
        }
        
        if closed &&
            points.count > 0 {
            points.append(points.first!)
        }
        
        let path = CGMutablePath()
        path.addLines(between: points)
        
        return path
    }
    
    func createShadow(from edges: OrderedSet<Hexagon.Edge>, styler: (SKShapeNode)->SKNode) {
        let radius:CGFloat = 100
        let topology = orientation.topology(radius: radius)
        let points = edges.map { edge in
            topology.plot(for: edge, of: radius)
        }
        var connectedPoints = points
        connectedPoints.append(points.first!)
        
        let node = SKShapeNode(points: &connectedPoints, count: connectedPoints.count)
        
        let styledNode = styler(node)
        
        scene!.addChild(styledNode)
    }
    
    func applyEdgeAdorners(from edges: [Hexagon.Edge], continous: Bool = false, applier: (HexagonMapNode, Int, CGPoint) -> Void) {
        let radius: CGFloat = 100
        
        let topology = orientation.topology(radius: radius)
        let points = edges.map { edge in
            topology.plot(for: edge, of: radius)
        }
        
        for (index,
             point) in points.enumerated() {
            applier(self, index,point)
        }
    }
    
    func findHex(at position: CGPoint) -> (Coordinates,CGPoint)? {
        var coordinates: Coordinates? = nil
        
        for child in self.children {
            guard let child = child as? HexagonNode else { continue }
            
            let position = self.convert(position, to: child)
            
            guard child.path!.contains(position) else { continue }
            
            coordinates = child.hexagon.coordinates
            return (coordinates ?? (x: 0, y: 0), position)
        }
        
        return nil
    }
    
    func findHexNode(at hex: (Int, Int) ) -> HexagonNode {
        let hexName = Hexagon.nameFrom(coordinates: hex)
        return self.childNode(withName: hexName) as! HexagonNode
    }
    
    func contains(point: CGPoint) -> Bool {
        findHex(at: point) != nil
    }
    
    func convert(position venuePosition: VenuePosition) -> CGPoint {
        let possibleHex = self.childNode(withName: Hexagon.nameFrom(coordinates: venuePosition.hex))
        guard let hex = possibleHex as? HexagonNode else { return .zero }
        let position = hex.convert(CGPoint(x: venuePosition.x, y: venuePosition.y), to: hex.parent!)
        let result = CGPoint(x: position.x, y: position.y)
        return result
    }
    
    func convert(point: CGPoint) -> VenuePosition {
        let (coordinates, position) = self.findHex(at: point)!
        return VenuePosition(coordinates, position)
    }
    
    func randomPoint() -> CGPoint {
        var point: CGPoint = .zero
        
        while true {
            let hex = region.randomHex()
            let innerPoint = self.orientation.topology(radius: 100).randomPoint()
            let venuePosition = VenuePosition(hex, innerPoint)
            point = self.convert(position: venuePosition)
            if point != .zero && self.contains(point: point) {
                break
            }
        }
        
        return point
    }
}
