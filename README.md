## WaveMenu

WaveMenu is an animated, custom menu view.  

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## Demo
<p align="center">
  <img alt="Custom Content" src="Docs/wave.gif">
</p>

## Requirements
* iOS 10.0+
* Xcode 11+
* Swift 5.2+

## Installation
WaveMenu is distributed with [Swift Package Manager](https://swift.org/package-manager/) which is the only official distribution tool by Apple. You can add WaveMenu to your project from Xcode's `File > Swift Packages > Add Package Dependency` menu with its github URL:
```
https://github.com/mobven/WaveMenu.git
```

## Usage

WaveMenu can initialize from storyboard or programmatically. WaveMenu gives an index of selected title attribute via `WaveMenuDelegate`, for doing this, `menuDelegate` has to set. Do not forget to set WaveMenu view `backgroundColor` attribute.

### Supported Attributes

- titleNames                                   -> Displayed menu items.                              (String Array)
- curveWidth                                  -> Curve's bottom width.                               (Int)
- titleFont                                       -> Menu item's font.                                       (UIFont)
- menuTitleTextColor                     -> Menu item text color.                                 (UIColor)
- menuTitleSelectedTextColor       -> Selected menu item text color.                  (UIColor)
- curveFillColor                              -> Curve's fill color                                         (UIColor)
- curveDotColor                             -> DotView color                                            (UIColor)
- bottomViewPaddaing                  -> BottomView leading and trailing pading   (CGFloat)
- programmaticallySelectedIndex -> Menu index that selected programmatically (Int)

### Programmatically Initialize

- Create a WaveMenu instance and add as a subview.

  ```swift
    let topBar: WaveMenu = {
        let wm = WaveMenu()
        wm.backgroundColor = UIColor(red: 232/255, green: 35/255, blue: 55/255, alpha: 1.0)
        wm.titleNames = ["Budget", "Transaction", "Overview"]
        wm.curveWidth = 24
        wm.titleFont = UIFont(name: "Noteworthy-Light", size: 15)!
        wm.menuTitleTextColor = .init(white: 1.0, alpha: 0.6)
        wm.menuTitleSelectedTextColor = .white
        wm.curveFillColor = .white
        return wm
    }()
  ```
  ```swift
    override func viewDidLoad() {
        super.viewDidLoad()
    
       view.addSubview(topBar)
       topBar.menuDelegate = self
       // set constraints of topBar
    }
  ```
  

### Storyboard Initialization

<p align="center">
  <img alt="Storyboard init" src="Docs/storyboard_init.png">
</p>

- Create a view from storyboard.
- Select view and set custom class in the identity inspector with `WaveMenu`.
- Can set @IBInspactable params in attribute inspector.
- Create an outlet and set attributes for WaveMenu instance.


## What's next
- [ ] New animations for curve.
- [ ] Unit Tests.

---
Developed with 🖤 at [Mobven](https://mobven.com/)
