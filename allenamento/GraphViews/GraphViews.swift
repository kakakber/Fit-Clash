//
//  GraphViews.swift
//  allenamento
//
//  Created by Enrico on 10/04/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import Foundation
import Macaw


enum colorForChartBar{
    case arancio
    case verde
    case indico
}

class StatisticheAddView: MacawView {
    open var completionCallback: (() -> ()) = { }
    
    private var backgroundGroup = Group()
    private var mainGroup = Group()
    private var captionsGroup = Group()
    
    private var barAnimations = [Animation]()
    private var barsValues: [Int] = []
    private let barsCaptions: [Int] = []
    private var barsCount = 0
    private var ghSch = 326
    private var barsSpacing = 5
    private var barWidth = 10
    private var barHeight = 230
    
    //private let emptyBarColor = Color.rgba(r: 138, g: 147, b: 219, a: 0.5)
    private let emptyBarColor = Color.clear
    private var gradientColor = LinearGradient(degree: 90, from: Color(val: 0xff9500), to: Color(val: 0xff9500).with(a: 0.75))
    private var textColor = Color(val: 0xff9500)
    
    private var inMese = false
    
    func setBarUp(valori: [Int], larghezzaView: Int, altezzaView: Int, colore: colorForChartBar, inMeseI: Bool){
        self.barsValues = valori
        self.ghSch = larghezzaView
        self.barHeight = altezzaView
        self.barsCount = valori.count
        
        self.inMese = inMeseI
        
        switch colore {
        case .arancio:
            gradientColor = LinearGradient(degree: 90, from: Color(val: 0xff9500), to: Color(val: 0xff9500).with(a: 0.75))
            textColor = Color(val: 0xff9500)
        case .indico:
            gradientColor = LinearGradient(degree: 90, from: Color(val: 0x5856D6), to: Color(val: 0x5856D6).with(a: 0.75))
            textColor = Color(val: 0x5856D6)
        default:
            gradientColor = LinearGradient(degree: 90, from: Color(val: 0x34C759), to: Color(val: 0x34C759).with(a: 0.75))
            textColor = Color(val: 0x34C759)
        }
    }
    
    private func createScene() {
        //trovare un modo per scrivere meno cose più dati ci sono
        if barsCount == 0{
            barsSpacing = 20
        }else{
          barsSpacing = 40/barsCount
        }//?????????? BOOOOH O FAMO?  O FAMO!
        barWidth = (ghSch/barsCount)+barsSpacing
        let viewCenterX = Double(self.frame.width / 2)
        let barsWidth = Double((barWidth * barsCount) + (barsSpacing * (barsCount - 1)))
        let barsCenterX = viewCenterX - barsWidth / 2
        
        backgroundGroup = Group()
        for barIndex in 0...barsCount - 1 {
            let barShape = Shape(
                form: RoundRect(
                    rect: Rect(
                        x: Double(barIndex * (barWidth + barsSpacing)),
                        y: 0,
                        w: Double(barWidth),
                        h: Double(barHeight)
                    ),
                    rx: 5,
                    ry: 5
                ),
                fill: emptyBarColor
            )
            backgroundGroup.contents.append(barShape)
        }
        
        mainGroup = Group()
        for barIndex in 0...barsCount - 1 {
            let barShape = Shape(
                form: RoundRect(
                    rect: Rect(
                        x: Double(barIndex * (barWidth + barsSpacing)),
                        y: Double(barHeight),
                        w: Double(barWidth),
                        h: Double(0)
                    ),
                    rx: 5,
                    ry: 5
                ),
                fill: gradientColor
            )
            mainGroup.contents.append([barShape].group())
        }
        
        backgroundGroup.place = Transform.move(dx: barsCenterX, dy: 90)
        mainGroup.place = Transform.move(dx: barsCenterX, dy: 90)
        
        captionsGroup = Group()
        captionsGroup.place = Transform.move(
            dx: barsCenterX,
            dy: 100 + Double(barHeight)
        )
        for barIndex in 0...barsCount - 1 {
            var valzz = "\(Int(barsValues[barIndex]))"
            if inMese{
                valzz = " "
                if barsValues.max() == barsValues[barIndex]{
                    valzz = "\(Int(barsValues[barIndex]))"
                }
            }
            let text = Text(
                text: valzz,
                font: Font(name: "System", size: 11, weight: "Heavy"),
                fill: textColor
            )
            text.align = .mid
            text.place = .move(
                dx: Double((barIndex * (barWidth + barsSpacing)) + barWidth / 2),
                dy: 0
            )
            captionsGroup.contents.append(text)
        }
        /*
        var grp = Group()
        for (index, node) in mainGroup.contents.enumerated() {
            if let group = node as? Group {
                var heightValue : Double = 4
                if barsValues.max() != 0{
                    heightValue = Double(self.barHeight) / Double(barsValues.max()!) * Double(barsValues[index])
                    
                }
                print(heightValue)
                    let value = Double(heightValue)
                    let barShape = Shape(
                        form: RoundRect(
                            rect: Rect(
                                x: Double(index * (self.barWidth + self.barsSpacing)),
                                y: Double(self.barHeight) - Double(value),
                                w: Double(self.barWidth),
                                h: Double(value)
                            ),
                            rx: 5,
                            ry: 5
                        ),
                        fill: self.gradientColor
                    )
                grp.contents.append(contentsOf: [barShape])
            }
        }*/
        
        self.node = [backgroundGroup, mainGroup, captionsGroup].group()
        self.backgroundColor = .clear
    }
    
    private func createAnimations()->Group{
        barAnimations.removeAll()
        let grp = Group()
        for (index, node) in mainGroup.contents.enumerated() {
            if let group = node as? Group {
                var heightValue : Double = 4
                if barsValues.max() != 0{
                    heightValue = Double(self.barHeight) / Double(barsValues.max()!) * Double(barsValues[index])+4
                    
                }
                
                let animation = group.contentsVar.animation({ t in
                    let value = Double(heightValue) / 100 * (t * 100)
                    let barShape = Shape(
                        form: RoundRect(
                            rect: Rect(
                                x: Double(index * (self.barWidth + self.barsSpacing)),
                                y: Double(self.barHeight) - Double(value),
                                w: Double(self.barWidth),
                                h: Double(value)
                            ),
                            rx: 5,
                            ry: 5
                        ),
                        fill: self.gradientColor
                    )
                    grp.contents.append(barShape)
                    return [barShape]
                }, during: 0.0, delay: 0)
                barAnimations.append(animation)
            }
        }
        return grp
    }
    
    func onFin(){
        self.isHidden = false
    }
    
    open func play() {
        self.isHidden = true
        self.contentMode = .scaleAspectFit
        createScene()
        createAnimations()
        //super.node = node
       barAnimations.sequence().onComplete {
            //self.completionCallback()
        self.onFin()
        }.play()
    }
    /*static let data = getData()
    static let maxValue : Double = Double(data.addominali.max() ?? 20)
    static let maxValueLineHeight : Double = 230
    static let lineWidth: Double = 300
    
    static let dataDivisor = maxValue/maxValueLineHeight
    static let adjustedData: [Double] = data.addominali.map({Double($0)/dataDivisor})
    static var animations: [Animation] = []
    
    required init?(coder aDecoder: NSCoder){
        super.init(node: StatisticheAddView.createChart(), coder: aDecoder)
        backgroundColor = .clear
    }
    
    private static func createChart() -> Group{//Group= array of nodes with UIElements
        var items : [Node] = addXAxisItems()
        items.append(createBars())
        return Group(contents: items, place: .identity)
    }
    
    private static func addXAxisItems() -> [Node]{
        let baseY = 200
        let yAxisHeiht: Double = 200
        print(adjustedData)
        var newNodes: [Node] = []
        for c in 1...data.addominali.count{
            let x = (Double(c)*50)
            let valueText = Text(text: "04/23", align: .max, baseline: .mid, place: .move(dx: x, dy: Double(baseY+15)))
            valueText.fill = Color.black
            newNodes.append(valueText)
        }
        
        newNodes.append(Line(x1: 0, y1: Double(baseY), x2: lineWidth, y2: Double(baseY)).stroke(fill: Color(val: 0xff9500).with(a: 0.55)))
        
        return newNodes
    }
    private static func createBars() -> Group{
        let fill = LinearGradient(degree: 90, from: Color(val: 0xff9500), to: Color(val: 0xff9500).with(a: 0.55))
        let items = adjustedData.map{ _ in Group()}
        animations = items.enumerated().map{ (i: Int, item: Group) in
            item.contentsVar.animation(delay: 0){ t in
                let height = Double(adjustedData[i]) * t
                let rect = Rect(x: Double(i)*50+25, y: 200-height, w: 30, h: height)
                return [rect.fill(with: fill)]
            }
        }
        return items.group()
    }
    
    static func playAnimations(){
        animations.combine().play()
    }*/
}

