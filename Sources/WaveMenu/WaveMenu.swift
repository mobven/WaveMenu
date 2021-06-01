//
//  WaveMenu.swift
//  WaveMenu
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

    private let cellId = "waveCell"
    private let caLayer: CAShapeLayer = CAShapeLayer()

    ///  collection view delegate and data source holder
    private let wmCollectionViewInstance: WaveMenuCollectinViewController = WaveMenuCollectinViewController()

    /// hold the collection view selected index for drawing bezire curve
    private lazy var selectedCVIndex: Int = 0
    /// hold the collection view previous selected index for avoid reselection same cell
    private lazy var previousSelectedCVIndex: Int = 0

    /// Thanks to menuDelegate, collectionView's selected index become accessible
    ///  Example: didChangeWaveMenuItem(newIndex: Int) method
    public weak var menuDelegate: WaveMenuDelegate?
    
    /// Bezire curve's bottom width. Initially 72
    @IBInspectable open var curveWidth: Int = 72

    /// WaveMenu titles. Initial values: ["Title 1", "Title 2", "Title 3"]
    public var titleNames: [String] = ["Title 1", "Title 2", "Title 3"] {
        didSet {
            wmCollectionViewInstance.titleNames = titleNames
            resetViews()
        }
    }

    /// WaveMenu title font. Initial value: UIFont.systemFont(ofSize: 14)
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            wmCollectionViewInstance.titleFont = titleFont
            resetViews()
        }
    }

    /// WaveMenu title text color. Initial value: .black
    @IBInspectable public var menuTitleTextColor: UIColor = .black {
        didSet {
            wmCollectionViewInstance.menuTitleTextColor = menuTitleTextColor
            resetViews()
        }
    }

    /// WaveMenu selected title text color. Initial value: .white
    @IBInspectable public var menuTitleSelectedTextColor: UIColor = .white {
        didSet {
            wmCollectionViewInstance.menuTitleSelectedTextColor = menuTitleSelectedTextColor
            resetViews()
        }
    }

    /// Bezire curve fill color. Initial value: .white
    @IBInspectable public var curveFillColor: UIColor = .white {
        didSet {
            resetViews()
        }
    }

    /// Bezire curve dotView color. Initial value: .red
    @IBInspectable public var curveDotColor: UIColor = .red {
        didSet {
            dotView.backgroundColor = curveDotColor
        }
    }

    /// Gives same leading and trailing margin to the bottomView
    @IBInspectable public var bottomVievPadding: CGFloat = 0 {
        didSet {
            resetViews()
        }
    }

    /// This method reset collectionView and curve.
    private func resetViews() {
        // Deleting all views from superview for
        collectionView.removeFromSuperview()
        curveContainerView.removeFromSuperview()
        bottomView.removeFromSuperview()
        // Reinitialize views
        initializeViews()

        self.collectionView.reloadData()
        // resetting curve
        self.setCurve(firstCall: false)
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
        addSubview(collectionView)
        addSubview(bottomView)

        bottomView.backgroundColor = curveFillColor

        // Collection view and curveContainer constraints
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: curveContainerView)
        addConstraintsWithFormat("H:|-\(bottomVievPadding)-[v0]-\(bottomVievPadding)-|", views: bottomView)
        addConstraintsWithFormat("V:|[v0]-6-|", views: collectionView)
        addConstraintsWithFormat("V:[v0(20)]-6-|", views: curveContainerView)
        addConstraintsWithFormat("V:[v0(6)]|", views: bottomView)

        wmCollectionViewInstance.cellId = cellId
        wmCollectionViewInstance.selectedCVIndex = selectedCVIndex
        wmCollectionViewInstance.previousSelectedIndex = previousSelectedCVIndex
        wmCollectionViewInstance.curveListener = { [weak self] selectedIndex, prevSelectedIndex in
            self?.selectedCVIndex = selectedIndex
            self?.previousSelectedCVIndex = prevSelectedIndex
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

    /// This method transforms dotView from deselected cell to bottomView.
    private func transformDotViewToBottom(with middle: CGPoint,
                                          cellWidth: CGFloat,
                                          dotLeftPadding: CGFloat,
                                          dotRightPadding: CGFloat,
                                          curveControllerValue: Int) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
                if self.previousSelectedCVIndex > self.selectedCVIndex {
                    self.dotView.center = CGPoint(
                        x: (CGFloat(self.previousSelectedCVIndex) * cellWidth) + dotLeftPadding,
                        y: middle.y + self.bounds.height - 3
                    )
                } else {
                    self.dotView.center = CGPoint(
                        x: (CGFloat(self.previousSelectedCVIndex) * cellWidth) + dotRightPadding,
                        y: middle.y + self.bounds.height - 3
                    )
                }
            }, completion: { [weak self] _ in
                self?.transformDotViewToNewCell(with: middle, xPoint: CGFloat((curveControllerValue - 20)))
            })
        }
    }

    /// This method transforms dotView on the bottomView from deselected cell to selected cell.
    private func transformDotViewToNewCell(with middle: CGPoint, xPoint: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                if self.previousSelectedCVIndex > self.selectedCVIndex {
                    self.dotView.center = CGPoint(x: middle.x + xPoint, y: middle.y + self.bounds.height - 3)
                } else {
                    self.dotView.center = CGPoint(x: middle.x - xPoint, y: middle.y + self.bounds.height - 3)
                }
            }, completion: { [weak self] _ in
                self?.transformDotViewToNewLocation(with: middle)
            })
        }
    }

    /// This method transforms dotView from bottomView to selected cell.
    private func transformDotViewToNewLocation(with middle: CGPoint) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
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
            self.transformDotViewToBottom(with: middle,
                                          cellWidth: cvCellWidth,
                                          dotLeftPadding: dotLeftPadding,
                                          dotRightPadding: dotRightPadding,
                                          curveControllerValue: curveControllerValue)

            UIView.animate(withDuration: 0.25, delay: 0.10, options: .curveLinear, animations: {  [weak self] in
                self?.curveContainerView.center.y += 20
            }, completion: { [weak self] _ in
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
            }, completion: { [weak self] _ in
                self?.layoutIfNeeded()
            })
        }
    }

    /// This method adds dotView middle of the curve
    private func addDotView(to middle: CGPoint) {
        DispatchQueue.main.async {
            self.dotView.removeFromSuperview()
            self.addSubview(self.dotView)
            self.dotView.frame = CGRect(x: middle.x - 3,
                                        y: middle.y + self.bounds.height - 12,
                                        width: 6,
                                        height: 6)
        }
    }
}
