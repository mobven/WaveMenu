//
//  WaveMenu.swift
//  WaveBar
//
//  Created by Ali Hasanoğlu on 21.07.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import Foundation
import UIKit

public protocol WaveMenuDelegate: AnyObject {
    /// `WaveMenu` is a selectable, animated bar.
    /// - parameter newIndex: item index which selected from WaveMenu.
    func didChangeWaveMenuItem(newIndex: Int)
}

public class WaveMenu: UIView {

    private let cellId = "cellId"
    private let caLayer: CAShapeLayer = CAShapeLayer()

    ///  collection view delegate and data source holder
    private let wmCollectionViewInstance: WaveMenuCollectinViewController = WaveMenuCollectinViewController()

    /// hold the collection view selected index for drawing bezire curve
    private lazy var selectedCVIndex: Int = 0
    /// hold the collection view previous selected index for avoid reselection same cell
    private lazy var previousSelectedIndex: Int = 0

    /// Thanks to menuDelegate, collectionView's selected index become accessible
    ///
    ///
    ///  Example: didChangeWaveMenuItem(newIndex: Int) method
    ///
    public weak var menuDelegate: WaveMenuDelegate?

    /// curve's bottom width. Initially 72
    @IBInspectable open var curveWidth: Int = 72

    /// WaveMenu titles. Initial value: ["Title 1", "Title 2", "Title 3"]
    public var titleNames = ["Title 1", "Title 2", "Title 3"] {
        didSet {
            wmCollectionViewInstance.titleNames = titleNames
            self.collectionView.reloadData()
            self.resetViews()
        }
    }

    /// WaveMenu title font. Initial value: UIFont.systemFont(ofSize: 14)
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            wmCollectionViewInstance.titleFont = titleFont
            self.collectionView.reloadData()
            self.resetViews()
        }
    }

    /// WaveMenu title text color. Initial value: .black
    @IBInspectable public var menuTitleTextColor: UIColor = .black {
        didSet {
            wmCollectionViewInstance.menuTitleTextColor = menuTitleTextColor
            self.collectionView.reloadData()
            resetViews()
        }
    }

    /// WaveMenu selected title text color. Initial value: .white
    @IBInspectable public var menuTitleSelectedTextColor: UIColor = .white {
        didSet {
            wmCollectionViewInstance.menuTitleSelectedTextColor = menuTitleSelectedTextColor
            self.collectionView.reloadData()
            resetViews()
        }
    }

    /// Curve fill color. Initial value: .white
    @IBInspectable public var curveFillColor: UIColor = .white {
        didSet {
            self.resetViews()
        }
    }

    /// Curve dotView color. Initial value: .red
    @IBInspectable public var curveDotColor: UIColor = .red {
        didSet {
            dotView.backgroundColor = curveDotColor
        }
    }

    /// This method reset collectionView and curve.
    private func resetViews() {
        // Initial Selection
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
        // resetting curve
        self.setCurve(firstCall: false)
        bottomView.backgroundColor = curveFillColor
        self.clipsToBounds = true
    }

    // MARK: UI Componenets
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collView.backgroundColor = UIColor.clear
        collView.dataSource = wmCollectionViewInstance
        collView.delegate = wmCollectionViewInstance
        return collView
    }()

    /// Contains curve. Starting from waveMenu's leading to trailing and 20 pt. heights.
    private lazy var curveContainerView: UIView = {
        let view = UIView()
        return view
    }()

    /// BottomView for transforming dotView
    private lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3.0
        return view
    }()

    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeViews()
    }

    ///  This method adds collectionView, bottomView and curveContainerView to the waveMenu.
    ///  Besides, send needed datas to WaveMenuCollectinViewController and
    ///  manage callback from WaveMenuCollectinViewController.
    private func initializeViews() {
        collectionView.register(WMTitleCell.self, forCellWithReuseIdentifier: cellId)

        addSubview(curveContainerView)
        addSubview(bottomView)
        addSubview(collectionView)

        // Collection view and curveContainer constraints
        let cvCellWidth = self.frame.width / CGFloat(titleNames.count)
        let padding = cvCellWidth / 2 - 15
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: curveContainerView)
        addConstraintsWithFormat("H:|-\(padding)-[v0]-\(padding)-|", views: bottomView)
        addConstraintsWithFormat("V:|[v0]-6-|", views: collectionView)
        addConstraintsWithFormat("V:[v0(20)]-6-|", views: curveContainerView)
        addConstraintsWithFormat("V:[v0(6)]|", views: bottomView)

        wmCollectionViewInstance.cellId = cellId
        wmCollectionViewInstance.selectedCVIndex = selectedCVIndex
        wmCollectionViewInstance.previousSelectedIndex = previousSelectedIndex
        wmCollectionViewInstance.curveListener = { [weak self] selectedIndex, prevSelectedIndex in
            self?.selectedCVIndex = selectedIndex
            self?.previousSelectedIndex = prevSelectedIndex
            self?.hideCurveContainerView()
            if self?.menuDelegate != nil {
                self?.menuDelegate?.didChangeWaveMenuItem(newIndex: selectedIndex)
            }
        }
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        setCurve(firstCall: true)
    }

    /// Bezire curve settings
    private func setCurve(firstCall: Bool) {

        let curveControllerValue = curveWidth / 2

        // collectionView cell width
        let cvCellWidth = self.frame.width / CGFloat(titleNames.count)

        // curve's initial x point
        let startXPoint = (Int(cvCellWidth) * selectedCVIndex) + (Int(cvCellWidth / 2) - curveControllerValue)

        // curve's last x point
        let endXPoint = (Int(cvCellWidth) * selectedCVIndex) + (Int(cvCellWidth / 2) + curveControllerValue)

        // curveContainerView height
        let layerHeight = curveContainerView.frame.height

        // curve's first point
        let firstPoint = CGPoint(x: Int(startXPoint), y: Int(layerHeight))
        // curve's mid point
        let middlePoint = CGPoint(x: startXPoint + ((endXPoint - startXPoint) / 2), y: 0)
        // curve's last point
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
        caLayer.fillColor = curveFillColor.cgColor

        // adiing curve to the layer of curveContainerView
        self.curveContainerView.layer.addSublayer(self.caLayer)
        if firstCall {
            self.addDotView(to: middlePoint)
        }
    }

    private func transformToBottom(to middle: CGPoint,
                                   cellWidth: CGFloat,
                                   dotLeftPadding: CGFloat,
                                   dotRightPadding: CGFloat,
                                   curveControllerValue: Int) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: { () -> Void in
                if self.previousSelectedIndex > self.selectedCVIndex {
                    self.dotView.center = CGPoint(x: (CGFloat(self.previousSelectedIndex) * cellWidth) + dotLeftPadding,
                                                  y: middle.y + self.bounds.height - 3)
                } else {
                    self.dotView.center = CGPoint(x:
                                                    (CGFloat(self.previousSelectedIndex) * cellWidth) + dotRightPadding,
                                                  y: middle.y + self.bounds.height - 3)
                }
            }, completion: { [weak self] _ in
                self?.transformToNewCell(middle, xPoint: CGFloat((curveControllerValue - 20)))
            })
        }
    }

    private func transformToNewCell(_ middle: CGPoint, xPoint: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: { () -> Void in
                if self.previousSelectedIndex > self.selectedCVIndex {
                    self.dotView.center = CGPoint(x: middle.x + xPoint, y: middle.y + self.bounds.height - 3)
                } else {
                    self.dotView.center = CGPoint(x: middle.x - xPoint, y: middle.y + self.bounds.height - 3)
                }
            }, completion: { [weak self] _ in
                self?.transformToDotLocation(middle)
            })
        }
    }

    private func transformToDotLocation(_ middle: CGPoint) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: { () -> Void in
                self.dotView.center = CGPoint(x: middle.x, y: middle.y + self.bounds.height - 12)
            }, completion: { [weak self] _ in
                self?.dotView.layer.animateForBounce()
            })
        }
    }

    /// This method animatedly hides curveContainerView and after completed shows new curve
    private func hideCurveContainerView() {

        let curveControllerValue = curveWidth / 2
        let cvCellWidth = self.frame.width / CGFloat(titleNames.count)
        let startXPoint = (Int(cvCellWidth) * selectedCVIndex) + (Int(cvCellWidth / 2) - curveControllerValue)
        let endXPoint = (Int(cvCellWidth) * selectedCVIndex) + (Int(cvCellWidth / 2) + curveControllerValue)
        // curve's mid point
        let middle = CGPoint(x: startXPoint + ((endXPoint - startXPoint) / 2), y: 0)

        //Right and left paddings when dot translate to bottom view
        let dotRightPadding: CGFloat = (cvCellWidth / 2) + (CGFloat(curveControllerValue) - 3)
        let dotLeftPadding: CGFloat = (cvCellWidth / 2) - (CGFloat(curveControllerValue) - 3)

        DispatchQueue.main.async {

        self.transformToBottom(to: middle,
                               cellWidth: cvCellWidth,
                               dotLeftPadding: dotLeftPadding,
                               dotRightPadding: dotRightPadding,
                               curveControllerValue: curveControllerValue)

            UIView.animate(withDuration: 0.25, delay: 0.10, options: .curveLinear, animations: {  [weak self] in
                self?.curveContainerView.center.y += 20
            }, completion: {[weak self] (_ : Bool) in
                self?.curveContainerView.isHidden = true
                self?.layoutIfNeeded()
                self?.showCurveContainerView()
            })
        }
    }

    /// This method show curveContainerView with new curve
    private func showCurveContainerView() {
        DispatchQueue.main.async {
            self.curveContainerView.isHidden = false
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: { [weak self] in
                /// resetting curve
                self?.setCurve(firstCall: false)
                self?.curveContainerView.center.y -= 20
            }, completion: { [weak self] (_: Bool) in
                self?.layoutIfNeeded()
            })
        }
    }

    /// This method adds dotView middle of the curve
    private func addDotView(to middle: CGPoint) {
        DispatchQueue.main.async {
            self.dotView.removeFromSuperview()
            self.addSubview(self.dotView)
            self.dotView.frame = CGRect(x: middle.x - 3, y: middle.y + self.bounds.height - 12, width: 6, height: 6)
        }
    }
}
