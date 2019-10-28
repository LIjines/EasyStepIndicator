//
//  EasyStepIndicator.swift
//  homesecurity
//
//  Created by DeshPeng on 2018/12/5.
//  Copyright © 2018年 Hub 6 Inc. All rights reserved.
//

import UIKit

public enum StepDirection: UInt {
    case leftToRight = 0, rightToLeft, topToBottom, bottomToTop
}

public enum IndicatorStartAligmentMode: UInt {
    case top = 0,//每个标题和圆圈的起始对齐
    center,//每个标题和起始和圆圈的中心对齐
    centerWithAnnularTopStart//标题和圆圈中心对齐,且强制以第一个圆圈的顶作为layer起始点,可能会超出superview
}

@IBDesignable
public class EasyStepIndicator: UIView {
    
    // Variables
    static let defaultColor = UIColor.red
    static let defaultTintColor = UIColor.green
    private var annularLayers = [AnnularLayer]()
    private var lineLayers = [LineLayer]()
    private var descriptionTextLayers = [DescriptionTextLayer]()
    private let containerLayer = CALayer()
    
    // MARK: - Properties
    override public var frame: CGRect {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //总步骤数量
    @IBInspectable public var numberOfSteps: Int = 5 {
        didSet {
            self.createSteps()
        }
    }
    //当前步骤
    @IBInspectable public var currentStep: Int = -1 {
        didSet {
            if self.annularLayers.count <= 0 {
                return
            }
            self.showLineAnimating = currentStep > oldValue
            self.setCurrentStep(step: self.currentStep)
        }
    }
    // MARK: - 指示圆框
    //圆大小
    @IBInspectable public var circleRadius: CGFloat = 20.0 {
        didSet {
            self.updateSubLayers()
        }
    }
    //指示圆框未完成时候的颜色
    @IBInspectable public var circleAnnularIncompleteColor: UIColor = defaultColor {
        didSet {
            self.updateSubLayers()
        }
    }
    //指示圆框完成时候的颜色
    @IBInspectable public var circleAnnularCompleteColor: UIColor = defaultTintColor {
        didSet {
            self.updateSubLayers()
        }
    }
    //指示圆框线条的宽度
    @IBInspectable public var circleStrokeWidth: CGFloat = 1.0 {
        didSet {
            self.updateSubLayers()
        }
    }
    //指示圆框虚线长度
    @IBInspectable public var circleAnnularLineDashWidth: Float = 3 {
        didSet {
            self.updateSubLayers()
        }
    }
    //指示圆框虚线间隔
    @IBInspectable public var circleAnnularLineDashMargin: Float = 3 {
        didSet {
            self.updateSubLayers()
        }
    }
    //圆内未完成时候的颜色
    @IBInspectable public var circleTintIncompleteColor: UIColor = defaultColor {
        didSet {
            self.updateSubLayers()
        }
    }
    //圆内完成时候的颜色
    @IBInspectable public var circleTintCompleteColor: UIColor = defaultTintColor {
        didSet {
            self.updateSubLayers()
        }
    }
    //指向线条未完成的颜色
    @IBInspectable public var lineIncompleteColor: UIColor = defaultColor {
        didSet {
            self.updateSubLayers()
        }
    }
    // MARK: - 连接线条
    
    //Line是否适应文字的高度,如果文字过多,建议开启,如果关闭的,Line的高度是与SuperView关联
    public var lineDynamicLength = false {
        didSet {
            self.updateSubLayers()
        }
    }
    
    public var lineMinMargin : CGFloat = 10 {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //指向线条完成的颜色
    @IBInspectable public var lineCompleteColor: UIColor = defaultTintColor {
        didSet {
            self.updateSubLayers()
        }
    }
    //指向线条离圆形的距离
    @IBInspectable public var lineMargin: CGFloat = 0.0 {
        didSet {
            self.updateSubLayers()
        }
    }
    //指向线条宽度
    @IBInspectable public var lineStrokeWidth: CGFloat = 4.0 {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //指向线条虚线间隔
    @IBInspectable public var lineImaginaryMargin: Float = 1 {
        didSet {
            self.updateSubLayers()
        }
    }
    //指向线条小虚线宽度
    @IBInspectable public var lineImaginaryWidth: Float = 5 {
        didSet {
            self.updateSubLayers()
        }
    }
    // MARK: - 整体
    //增长方向
    public var direction: StepDirection = .leftToRight {
        didSet {
            self.updateSubLayers()
        }
    }
    //增长方向RAW
    @IBInspectable var directionRaw: UInt {
        get {
            return self.direction.rawValue
        }
        set {
            let value = newValue > 3 ? 0 : newValue
            self.direction = StepDirection(rawValue: value)!
        }
    }
    //
    public var startAlignmentMode : IndicatorStartAligmentMode = .center {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //是否显示起始圆框
    @IBInspectable public var showInitialStep: Bool = true {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //强制当前视为未完成
    @IBInspectable public var currentStepAsIncomplete: Bool = false {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //MARK : 框内文字
    //是否显示框内文字
    @IBInspectable public var showCircleText: Bool = false {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //圆形内描述文字,建议只输入一个数字
    public var stepCircleTexts:[String] = []{
        didSet {
            self.updateSubLayers()
        }
    }
    
    //圆形内描述文字未完成时候颜色
    @IBInspectable public var circleTextIncompleteColor: UIColor = defaultTintColor  {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //圆形内描述文字完成时候颜色
    @IBInspectable public var circleTextCompleteColor: UIColor = defaultColor {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //是否显示步骤描述文字
    @IBInspectable public var showStepTitles: Bool = false {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //MARK: -步骤描述文字
    //步骤描述文字
    public var stepDescriptionTexts:[String] = []{
        didSet {
            self.updateSubLayers()
        }
    }
    
    //步骤描述文字未完成时候颜色
    @IBInspectable public var stepTitleIncompleteColor: UIColor = UIColor.red {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //步骤描述文字完成时候颜色
    @IBInspectable public var stepTitleCompleteColor: UIColor = UIColor.green {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //Indicator和Description之间Margin
    @IBInspectable public var stepTitleMargin : CGFloat = 3 {
        didSet {
            self.updateSubLayers()
        }
    }
    
    //步骤描述文字的大小
    @IBInspectable public var stepTitleFontSize : CGFloat = 18 {
        didSet {
            self.updateSubLayers()
        }
    }
    
//    private var maxFontWidth : CGFloat = UIScreen.main.bounds.width/3
    
    private var maxFontHeight = 0
    
    private var showLineAnimating = true
    
    private var textSizes : [CGRect] = []
    
    // MARK: - Functions
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setCurrentStep(step: self.currentStep)
        self.updateSubLayers()
        //这里计算高度
        self.updateContainerFrame()
    }
    
    private func createSteps() {
        
        self.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        self.containerLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        
        self.annularLayers.removeAll()
        self.lineLayers.removeAll()
        self.descriptionTextLayers.removeAll()
        
        assert(self.numberOfSteps > 0, "步骤数必须大于0")

        for i in 0..<self.numberOfSteps {
            let annularLayer = AnnularLayer.init()
            self.containerLayer.addSublayer(annularLayer)
            self.annularLayers.append(annularLayer)
            
            if (i < self.numberOfSteps - 1) {
                let lineLayer = LineLayer()
                self.containerLayer.addSublayer(lineLayer)
                self.lineLayers.append(lineLayer)
            }
            
            let descriptionLayer = DescriptionTextLayer()
            self.containerLayer.addSublayer(descriptionLayer)
            self.descriptionTextLayers.append(descriptionLayer)
        }
        
        self.layer.addSublayer(self.containerLayer)
        self.setCurrentStep(step: self.currentStep)
        self.updateSubLayers()
    }
    
    private func updateSubLayers() {
        
        self.containerLayer.frame = self.layer.bounds
        
        if self.direction == .leftToRight || self.direction == .rightToLeft {
            self.layoutHorizontal()
        } else {
            self.layoutVertical()
        }
        
        self.applyDirection()
    }
    
    private func updateContainerFrame() -> CGRect{
        if showStepTitles && lineDynamicLength  {
            
            //横向要算,要改变scrollview大小,整体宽度是从最左边到最右边
            //纵向要算,要改变scrollview大小,整体宽度是从最左边到最右边
        } else {
            return self.layer.bounds
        }
        return CGRect.init()
    }
    
    private func layoutHorizontal() {
        let maxFontWidth = UIScreen.main.bounds.width/3
        let diameter = self.circleRadius * 2
        let stepWidth = self.numberOfSteps == 1 ?
            0 : (self.containerLayer.frame.width - self.lineMargin * 2 - diameter) / CGFloat(self.numberOfSteps - 1)//每个步骤(一个圈加一整条线的宽度)
        var startY : CGFloat = 0
        var contentHeight : CGFloat = 0
        var size = CGSize.zero
        if showStepTitles {//上移
            if self.stepDescriptionTexts.count == 0 {
                return
            }
            #if DEBUG
            assert(self.stepDescriptionTexts.count == self.numberOfSteps, "文字数组个数与步骤数不符合")
            #else
            if self.stepDescriptionTexts.count > self.numberOfSteps {
                self.stepDescriptionTexts = self.stepDescriptionTexts.prefix(upTo: self.numberOfSteps)
            } else if self.stepDescriptionTexts.count < self.numberOfSteps{
                self.stepDescriptionTexts.append(contentsOf: Array.init(repeating: "", count: self.numberOfSteps - self.stepDescriptionTexts.count))
            }
            #endif
            
            size = getHorizontalMaxTextRect().size
            contentHeight = size.height + self.stepTitleMargin + diameter
            #if DEBUG
            assert(contentHeight < self.containerLayer.frame.height, "文字之间距离过高或者文字过于长,检查stepDescriptionTextMargin和文字长度")
            #else
            contentHeight = min(self.containerLayer.frame.height, contentHeight)
            #endif
            startY = (self.containerLayer.frame.height - contentHeight) / 2 + self.circleRadius
        } else {
            startY = self.containerLayer.frame.height / 2.0
        }
        
        for i in 0 ..< self.annularLayers.count {
            let annularLayer = self.annularLayers[i]
            let x = self.numberOfSteps <= 1 ?
                self.containerLayer.frame.width / 2.0 - self.circleRadius : self.lineMargin + CGFloat(i) * stepWidth
            annularLayer.frame = CGRect(x: x, y: startY - self.circleRadius, width: diameter, height: diameter)
            self.applyAnnularStyle(annularLayer: annularLayer, index: i)
            annularLayer.step = i + 1
            annularLayer.updateStatus()
            
            if (i < self.numberOfSteps - 1) {
                let lineBackgroundHeight: CGFloat = self.lineStrokeWidth
                var y : CGFloat = 0.0
                if showStepTitles {//上移
                    y = (self.containerLayer.frame.height - contentHeight) / 2 + self.circleRadius - lineBackgroundHeight / 2.0
                } else {
                    y = self.containerLayer.frame.height / 2.0 - lineBackgroundHeight / 2.0
                }
                let lineLayer = self.lineLayers[i]
                lineLayer.frame = CGRect(x: CGFloat(i) * stepWidth + diameter + self.lineMargin * 2, y: y, width: stepWidth - diameter - self.lineMargin * 2, height: lineBackgroundHeight)
                self.applyLineStyle(lineLayer: lineLayer)
                lineLayer.updateStatus()
            }
            
            if showStepTitles {
                let descriptionStartY = startY + self.circleRadius + self.stepTitleMargin
                let descriptionStartX = x + self.circleRadius - maxFontWidth/2//TODO:计算长度
                let descriptionLayer = self.descriptionTextLayers[i]
                self.applyDescriptionText(descriptionText: descriptionLayer, index: i)
                descriptionLayer.frame = CGRect.init(x: descriptionStartX, y: descriptionStartY, width: maxFontWidth, height: size.height + 2)//修正两个像素
                descriptionLayer.updateStatus()
            }
            
        }
    }
    
    private func layoutVertical() {
        let diameter = self.circleRadius * 2
        var stepHeights : [CGFloat] = []
        
        if showStepTitles  {
            if self.stepDescriptionTexts.count == 0 {
                return
            }
            #if DEBUG
            assert(self.stepDescriptionTexts.count == self.numberOfSteps, "文字数组个数与步骤数不符合")
            #else
            if self.stepDescriptionTexts.count > self.numberOfSteps {
                self.stepDescriptionTexts = self.stepDescriptionTexts.prefix(upTo: self.numberOfSteps)
            } else if self.stepDescriptionTexts.count < self.numberOfSteps{
                self.stepDescriptionTexts.append(contentsOf: Array.init(repeating: "", count: self.numberOfSteps - self.stepDescriptionTexts.count))
            }
            #endif
            let maxFontWidth = self.containerLayer.frame.width - stepTitleMargin - diameter
            textSizes = self.stepDescriptionTexts.compactMap { (target) -> CGRect in
                let style = NSMutableParagraphStyle()
                style.alignment = NSTextAlignment.center
                return self.getTextRect(style: style, text: target, maxWidth: maxFontWidth)
            }
            
            if lineDynamicLength {//每个步骤的高度不一样
                var textHeights = textSizes.map { $0.height }
                while textHeights.count >= 2 {
                    let firstHeight = textHeights.removeFirst()
                    let stepHeight = max(firstHeight / 2,self.circleRadius) + max((textHeights.first!) / 2,self.circleRadius) - self.lineMargin * 2 + lineMinMargin - diameter // 线中间留10px空间,可以更改,看需求
                    stepHeights.append(stepHeight)
                }
            } else {//每个步骤高度一样
                var stepHeight : CGFloat = 0
                let textHeights = textSizes.map { $0.height }
                if self.numberOfSteps > 1 {
                    let topContentPadding = textHeights.first!/2 > self.circleRadius ? textHeights.first!/2 - self.circleRadius : 0
                    let bottomContentPadding =  textHeights.last!/2 > self.circleRadius ? textHeights.last!/2 - self.circleRadius : 0
                    
                    let totalStepHeight = self.containerLayer.frame.height - topContentPadding - bottomContentPadding - self.lineMargin * 2 * CGFloat(self.numberOfSteps - 1) - diameter * CGFloat(self.numberOfSteps)
                    stepHeight = totalStepHeight / CGFloat(self.numberOfSteps - 1)//单纯是线的长度
                }
                stepHeights = Array.init(repeating: stepHeight, count: self.numberOfSteps - 1)
            }
            
            for i in 0..<self.annularLayers.count {
                var y : CGFloat = 0
                if lineDynamicLength {
                    var topContentPadding : CGFloat = 0
                    let totalHeight = textSizes.reduce(-lineMinMargin) { (r, rect) -> CGFloat in
                        let textHeight = rect.height
                        return max(textHeight,diameter) + r + lineMinMargin
                    }
                    topContentPadding = (self.containerLayer.frame.height - totalHeight)/2 // 可以为负
                    var firstAnnulayerStartY : CGFloat = 0
                    if (textSizes.first?.height ?? 0)/2 - self.circleRadius > 0 {
                        firstAnnulayerStartY = topContentPadding + (textSizes.first?.height ?? 0)/2 - self.circleRadius
                    } else {
                        firstAnnulayerStartY = topContentPadding
                    }
                    y = firstAnnulayerStartY + CGFloat(i) * diameter + 2 * CGFloat(i) * self.lineMargin + stepHeights.prefix(upTo: i).reduce(0, +)
                    
                    applyVerticalContentLayer(annularLayerY: y, index: i, stepHeights: stepHeights)//防止这里超界
                } else {
                    var firstAnnulayerStartY : CGFloat = 0
                    if (textSizes.first?.height ?? 0)/2 - self.circleRadius > 0 {
                        firstAnnulayerStartY = (textSizes.first?.height ?? 0)/2 - self.circleRadius
                    } else {
                        firstAnnulayerStartY = 0
                    }
                    let stepHeight = stepHeights.first!
                    y = firstAnnulayerStartY + CGFloat(i) * (stepHeight + self.lineMargin * 2 + diameter)
                    applyVerticalContentLayer(annularLayerY: y, index: i, stepHeights: stepHeights)//防止这里超界
                }
            }
        } else {
            let stepHeight = self.numberOfSteps <= 1 ?
                0 : (self.containerLayer.frame.height - self.lineMargin * 2 * CGFloat(self.numberOfSteps - 1) -  diameter * CGFloat(self.numberOfSteps)) / CGFloat(self.numberOfSteps - 1)//单纯是线的长度
            stepHeights = Array.init(repeating: stepHeight, count: self.numberOfSteps - 1)
            for i in 0..<self.annularLayers.count {
                
                let y : CGFloat = self.numberOfSteps <= 1 ?
                    self.containerLayer.frame.height / 2.0 - self.circleRadius :
                    (diameter + stepHeight + 2 * lineMargin) * CGFloat(i)
                
                applyVerticalContentLayer(annularLayerY: y, index: i, stepHeights: stepHeights)
            }
        }
        
        //stepLineFitDescriptionText
        //1.高度弹性
        //先得出数组整组文字的长和高
        //选出最长一组,计算起始X的位置,记得加上之间的Margin
        //算出线的长短(文字高度+10)
        //得出文字的起始Y
        //2.高度相等
        //算出线的长短
        //先得出数组整组文字的长和高
        //得出文字起始位置
    }
    
    fileprivate func getTextRect(style: NSMutableParagraphStyle, text: String = "" , maxWidth : CGFloat) -> CGRect {
        let font = UIFont.systemFont(ofSize: stepTitleFontSize)
        let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style]
        let attributesText = NSAttributedString(string: text, attributes: attributes)
        let size = attributesText.boundingRect(with: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, context: nil)
        return size
    }
    
    private func getHorizontalMaxTextRect() -> CGRect {
        let text = self.stepDescriptionTexts.reduce(self.stepDescriptionTexts.first ?? "") {return $0.count > $1.count ? $0: $1 }
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return getTextRect(style: style, text: text, maxWidth: CGFloat(MAXFLOAT))
    }
    
    fileprivate func applyVerticalContentLayer( annularLayerY: CGFloat,index: Int, stepHeights:[CGFloat]) {
        let startX = showStepTitles ? self.circleRadius : self.containerLayer.frame.width / 2.0//综合加上字的长度
        let diameter = self.circleRadius * 2
        let annularLayer = self.annularLayers[index]
        annularLayer.frame = CGRect(x: startX - self.circleRadius, y: annularLayerY, width: diameter, height: diameter)
        self.applyAnnularStyle(annularLayer: annularLayer, index: index)
        annularLayer.step = index + 1
        annularLayer.updateStatus()
        
        if index < self.numberOfSteps - 1 {
            let lineLayer = self.lineLayers[index]
            let lineBackgroundWidth: CGFloat = self.lineStrokeWidth
            let lineX = showStepTitles ? startX - self.lineStrokeWidth/2 : self.containerLayer.frame.width / 2.0 - lineBackgroundWidth / 2.0
            let lineY = annularLayerY + diameter + self.lineMargin
            lineLayer.frame = CGRect(x: lineX, y: lineY, width: lineBackgroundWidth, height: stepHeights[index])
            lineLayer.isHorizontal = false
            self.applyLineStyle(lineLayer: lineLayer)
        }
        
        if showStepTitles {
            var descriptionStartY : CGFloat = 0.0
            if lineDynamicLength {
                descriptionStartY = annularLayerY + self.circleRadius - textSizes[index].height/2
            } else {
                let textHeights = textSizes.map { $0.size.height }
                descriptionStartY = annularLayerY + self.circleRadius - textHeights[index]/2
            }
            
            let descriptionStartX = startX + stepTitleMargin + self.circleRadius
            let descriptionLayer = self.descriptionTextLayers[index]
            self.applyDescriptionText(descriptionText: descriptionLayer, index: index)
            descriptionLayer.frame = CGRect.init(x: descriptionStartX, y: descriptionStartY, width: textSizes[index].size.width, height: textSizes[index].size.height)
            descriptionLayer.updateStatus()
        }
    }
    
    private func applyAnnularStyle(annularLayer: AnnularLayer, index: Int) {
        if !showInitialStep && (index == 0) {
            annularLayer.circleBorderIncompleteColor = UIColor.clear
            annularLayer.circleBorderCompleteColor = UIColor.clear
            annularLayer.incompleteTintColor = UIColor.clear
            annularLayer.completeTintColor = UIColor.clear
        } else {
            annularLayer.circleBorderIncompleteColor = self.circleAnnularIncompleteColor
            annularLayer.circleBorderCompleteColor = self.circleAnnularCompleteColor
            annularLayer.incompleteTintColor = self.circleTintIncompleteColor
            annularLayer.completeTintColor = self.circleTintCompleteColor
        }
        
        if showCircleText {
            self.applyStepText(annularLayer: annularLayer, index: index)
        }
        
        annularLayer.lineWidth = self.circleStrokeWidth
        annularLayer.lineDashPattern = [NSNumber.init(value: self.circleAnnularLineDashWidth), NSNumber.init(value: self.circleAnnularLineDashMargin)]
    }
    
    private func applyStepText(annularLayer: AnnularLayer, index: Int) {
        annularLayer.showCircleText = true
        annularLayer.circleTextCompleteColor = self.circleTextCompleteColor
        annularLayer.circleTextIncompleteColor = self.circleTextIncompleteColor
        if stepCircleTexts.count > index {
            annularLayer.stepCircleText = stepCircleTexts[index]
        }
    }
    
    private func applyDescriptionText(descriptionText: DescriptionTextLayer, index: Int) {
        descriptionText.stepDescriptionTextCompleteColor = self.stepTitleCompleteColor
        descriptionText.stepDescriptionTextIncompleteColor = self.stepTitleIncompleteColor
        descriptionText.stepDescriptionTextFontSize = self.stepTitleFontSize
        if stepDescriptionTexts.count > index {
            descriptionText.stepDescriptionText = stepDescriptionTexts[index]
        }
    }
    
    private func applyLineStyle(lineLayer: LineLayer) {
        lineLayer.defaultColor = self.lineIncompleteColor
        lineLayer.tintColor = self.lineCompleteColor
        lineLayer.lineWidth = self.lineStrokeWidth
        lineLayer.updateStatus()
    }
    
    private func applyDirection() {
        switch self.direction {
        case .rightToLeft:
            let rotation180 = CATransform3DMakeRotation(CGFloat.pi, 0.0, 1.0, 0.0)
            self.containerLayer.transform = rotation180
            for annularLayer in self.annularLayers {
                annularLayer.transform = rotation180
            }
            if showStepTitles {
                self.descriptionTextLayers.forEach { $0.transform = rotation180 }
            }
        case .bottomToTop:
            let rotation180 = CATransform3DMakeRotation(CGFloat.pi, 1.0, 0.0, 0.0)
            self.containerLayer.transform = rotation180
            for annularLayer in self.annularLayers {
                annularLayer.transform = rotation180
            }
            if showStepTitles {
                self.descriptionTextLayers.forEach { $0.transform = rotation180 }
            }
        default:
            self.containerLayer.transform = CATransform3DIdentity
            for annularLayer in self.annularLayers {
                annularLayer.transform = CATransform3DIdentity
            }
        }
    }
    
    private func setCurrentStep(step: Int) {
        for i in 0 ..< self.numberOfSteps {
            self.setAnnular(isFinished: i < step, isCurrent: i == step, index: i)
            self.setLine(isFinished: self.annularLayers[i].isFinished, isCurrent: self.annularLayers[i].isCurrent, index: i-1)
            self.setDescriptionText(isFinished: self.annularLayers[i].isFinished, isCurrent: self.annularLayers[i].isCurrent, index: i)
        }
    }
    
    private func setAnnular(isFinished: Bool, isCurrent: Bool, index: Int){
        self.annularLayers[index].isCurrent = isCurrent
        self.annularLayers[index].isFinished = isFinished
        self.annularLayers[index].currentStepAsIncomplete = self.currentStepAsIncomplete
        self.annularLayers[index].updateStatus()
    }
    
    private func setLine(isFinished: Bool, isCurrent: Bool, index: Int) {
        if index >= 0 {
            self.lineLayers[index].showAnimating = self.showLineAnimating
            self.lineLayers[index].currentStepAsIncomplete = currentStepAsIncomplete
            self.lineLayers[index].isFinished = isFinished
            self.lineLayers[index].isCurrent = isCurrent
            if isFinished {
                self.lineLayers[index].lineDashPattern = nil
            } else if isCurrent{
                self.lineLayers[index].lineDashPattern = currentStepAsIncomplete ? [NSNumber.init(value: self.lineImaginaryWidth), NSNumber.init(value: self.lineImaginaryMargin)]: nil
            } else {
                self.lineLayers[index].lineDashPattern = [NSNumber.init(value: self.lineImaginaryWidth), NSNumber.init(value: self.lineImaginaryMargin)]
            }
            self.lineLayers[index].updateStatus()
        }
    }
    
    private func setDescriptionText(isFinished: Bool, isCurrent: Bool, index: Int) {
        if index >= 0 {
            self.descriptionTextLayers[index].currentStepAsIncomplete = currentStepAsIncomplete
            self.descriptionTextLayers[index].isFinished = isFinished
            self.descriptionTextLayers[index].isCurrent = isCurrent
        }
    }
}
