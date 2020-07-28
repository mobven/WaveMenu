//
//  WaveMenu.swift
//  WaveBar
//
//  Created by Ali Hasanoğlu on 21.07.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import Foundation
import UIKit

public protocol WaveMenuDelegate: AnyObject{
    /// `WaveMenu` is a selectable, animated bar.
    /// - parameter newIndex: item index which selected from WaveMenu.
    func didChangeWaveMenuItem(newIndex: Int)
}

class WaveMenu: UIView {
    
    private let cellId = "cellId"
    private let caLayer: CAShapeLayer = CAShapeLayer()
    private lazy var selectedCVIndex: Int = 0 // hold the collection view selected index for drawing bezire curve
    private lazy var previousSelectedIndex: Int = 0 // hold the collection view previous selected index for avoid reselection same cell
    
    weak var menuDelegate: WaveMenuDelegate?
    
    open var curveWidth: Int = 24  // setting curve's width
    
    var titleNames = ["Title 1", "Title 2", "Title 3"]{
        didSet{
            self.collectionView.reloadData()
            self.initialSettings()
        }
    }
    
    
    var titleFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet{
            self.collectionView.reloadData()
            self.initialSettings()
        }
    }
    
    var menuTitleTextColor: UIColor = .black{
        didSet{
            self.collectionView.reloadData()
            self.initialSettings()
        }
    }
    
    var menuTitleSelectedTextColor: UIColor = .white{
        didSet{
            self.collectionView.reloadData()
            self.initialSettings()
        }
    }
    
    func initialSettings(){
        // Initial Selection
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
        // resetting curve
        self.resetCurve()
        dotView.backgroundColor = self.backgroundColor
    }
    
    // UI Componenets
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    lazy var curveContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3.0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(WMTitleCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(curveContainerView)
        addSubview(collectionView)
        
        // Collection view and curveContainer constraints
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: curveContainerView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:[v0(20)]|", views: curveContainerView)
        
        // Initial Selection
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        resetCurve()
    }
    
    
    // Bezire curve settings
    func resetCurve(){
        
        let curveControllerValue = curveWidth
        
        // collectionView cell width
        let cvCellWidth = curveContainerView.frame.width / CGFloat(titleNames.count)
        
        // curve's initial x point
        let startXPoint = (Int(cvCellWidth) * selectedCVIndex) + (Int(cvCellWidth / 2) - curveControllerValue)
        
        // curve's last x point
        let endXPoint = (Int(cvCellWidth) * selectedCVIndex) + (Int(cvCellWidth / 2) + curveControllerValue)
        
        // curveContainerView height
        let layerHeight = curveContainerView.frame.height
        
        // curve's first, mid and last points
        let firstPoint = CGPoint(x: Int(startXPoint), y: Int(layerHeight))
        let middlePoint = CGPoint(x: startXPoint + ((endXPoint - startXPoint) / 2), y: 0)
        let lastPoint = CGPoint(x: Int(endXPoint), y: Int(layerHeight))
        
        // curve's control points
        let firstPointFirstCurve = CGPoint(x: CGFloat(startXPoint + (curveControllerValue / 2)), y: layerHeight)
        let firstPointSecondCurve = CGPoint(x: CGFloat(startXPoint + (curveControllerValue / 2)), y: 0)
        
        let middlePointFirstCurve = CGPoint(x: CGFloat(endXPoint - (curveControllerValue / 2)), y: 0)
        let middlePointSecondCurve = CGPoint(x: CGFloat(endXPoint - (curveControllerValue / 2)), y: layerHeight)
        
        // draw curve via BezierPath
        let bezierPath = UIBezierPath()
        bezierPath.move(to: firstPoint)
        bezierPath.addCurve(to: middlePoint, controlPoint1: firstPointFirstCurve, controlPoint2: firstPointSecondCurve)
        bezierPath.addCurve(to: lastPoint, controlPoint1: middlePointFirstCurve, controlPoint2: middlePointSecondCurve)
        
        // add created path to CAShapeLayer and add to layer
        caLayer.path = nil
        caLayer.path = bezierPath.cgPath
        caLayer.fillColor = UIColor.white.cgColor
        
        
        // shake animation
        self.addShakeAnimation(to: caLayer)
        
        // adiing curve to the layer of curveContainerView
        self.curveContainerView.layer.addSublayer(self.caLayer)
        
        // adding middle dot view
        self.addDotView(to: middlePoint)
    }
    
    // shake animation
    func addShakeAnimation(to layer: CAShapeLayer){
        DispatchQueue.main.async {
            let animation = CAKeyframeAnimation()
            animation.keyPath = "position.x"
            animation.values = [0, 5, -5, 4, -4, 3, -3, 0 ]
            animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
            animation.duration = 0.8
            animation.isAdditive = true
            self.caLayer.add(animation, forKey: "shake")
        }
    }
    
    // hide CurveContainerView
    func hideCurveContainerView(){
        hideDotView()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {  [weak self] in
                self?.curveContainerView.center.y += 20
            }) { [weak self] (success: Bool) in
                self?.curveContainerView.isHidden = true
                self?.layoutIfNeeded()
                self?.showCurveContainerView()
            }
        }
    }
    
    // show CurveContainerView
    func showCurveContainerView(){
        showDotView()
        DispatchQueue.main.async {
            self.curveContainerView.isHidden = false
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: { [weak self] in
                // resetting curve
                self?.resetCurve()
                self?.curveContainerView.center.y -= 20
            }) { [weak self] (success: Bool) in
                self?.layoutIfNeeded()
            }
        }
    }
    
    // hide DotView
    func hideDotView(){
        DispatchQueue.main.async {
            self.dotView.isHidden = true
            self.layoutIfNeeded()
        }
    }
    
    // show DotView
    func showDotView(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0, delay: 0.14, options: .curveLinear, animations: {
            }) { [weak self] (success: Bool) in
                self?.dotView.isHidden = false
                self?.layoutIfNeeded()
            }
        }
    }
    
    // add DotView
    func addDotView(to middle: CGPoint){
        DispatchQueue.main.async {
            self.dotView.removeFromSuperview()
            self.curveContainerView.addSubview(self.dotView)
            if middle.x > 3{
                self.addConstraintsWithFormat("H:|-\(middle.x - 3)-[v0(6)]|", views: self.dotView)
                self.addConstraintsWithFormat("V:|-6-[v0(6)]|", views: self.dotView)
            }
        }
    }
}


// MARK: CollectionView Delegate - DataSource - FlowLayout
extension WaveMenu: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! WMTitleCell
        cell.titleLabel.font = self.titleFont
        cell.titleLabelTextColor = menuTitleTextColor
        cell.titleLabelSelectedTextColor = menuTitleSelectedTextColor
        cell.initViews(title: titleNames[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / CGFloat(titleNames.count), height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        previousSelectedIndex = selectedCVIndex
        selectedCVIndex = indexPath.row
        if previousSelectedIndex != selectedCVIndex{ // avoiding reselection the same cell
            hideCurveContainerView()
        }
        if menuDelegate != nil {
            menuDelegate?.didChangeWaveMenuItem(newIndex: selectedCVIndex)
        }
    }
}
