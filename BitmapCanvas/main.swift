//
//  main.swift
//  BitmapCanvas
//
//  Created by nst on 28/02/16.
//  Copyright © 2016 Nicolas Seriot. All rights reserved.
//

import Foundation
import AppKit

func switzerland() {

    guard let resultsData = NSData(contentsOfFile: "/Users/nst/Projects/BitmapCanvas/files/results.json") else { return }
    guard let optResults = try? NSJSONSerialization.JSONObjectWithData(resultsData, options: []) as? [String:AnyObject] else { return }
    guard let results = optResults else { return }

    guard let switzerlandData = NSData(contentsOfFile: "/Users/nst/Projects/BitmapCanvas/files/switzerland.json") else { return }
    guard let optSwitzerland = try? NSJSONSerialization.JSONObjectWithData(switzerlandData, options: []) as? [String:AnyObject] else { return }
    guard let switzerland = optSwitzerland else { return }
    
    let b = BitmapCanvas(365, 235, backgroundColor: NSColor.whiteColor())

    b.image(fromPath: "/Users/nst/Projects/BitmapCanvas/files/switzerland.gif", P(0,0))
    
    b.fill(P(0,0), color: NSColor.whiteColor())
    b.fill(P(0,170), color: NSColor.whiteColor())
    b.fill(P(300,0), color: NSColor.whiteColor())
    b.fill(P(355,110), color: NSColor.whiteColor())
    b.fill(P(300,190), color: NSColor.whiteColor())

    let font = NSFont(name: "Monaco", size: 10)!
    b.text("2016-02-28 \"Pas de spéculation sur les denrées alimentaires\"", P(5,220), font:font)
    
    let values : [Double] = results.flatMap { (k,v) in v as? Double }
    
    let positiveValues = values.filter { $0 >= 50.0 }
    let negativeValues = values.filter { $0 < 50.0 }
    
    let minPositive = positiveValues.minElement() ?? 0.0
    let maxPositive = positiveValues.maxElement() ?? 0.01

    let minNegative = negativeValues.minElement() ?? 0.0
    let maxNegative = negativeValues.maxElement() ?? 0.01
    
    let positiveRange = maxPositive - minPositive
    let negativeRange = maxNegative - minNegative
    
    print(minPositive, maxPositive)
    print(minNegative, maxNegative)
    
    for (k, cantonDict) in switzerland {

        guard let labelPoint = cantonDict["label"] as? [Int] else { continue }

        // fill color
        
        var fillColor = NSColor.lightGrayColor()
        if let percent = results[k] as? Double {
            if percent < 50.0 {
                let i = ((percent - minNegative) / negativeRange) - 0.15
                fillColor = NSColor(calibratedRed: 1.0, green: CGFloat(i), blue: CGFloat(i), alpha: 1.0)
            } else {
                let i = (1.0 - (percent - minPositive) / positiveRange) - 0.15
                fillColor = NSColor(calibratedRed: CGFloat(i), green: 1.0, blue: CGFloat(i), alpha: 1.0)
            }
        }
        
        // fill cantons
        
        let fillPoints = cantonDict["fill"] as? [[Int]] ?? [labelPoint]
        
        for pts in fillPoints {
            let px = pts[0]
            let py = pts[1]
            let p = P(CGFloat(px), CGFloat(py))
            b.fill(p, color: fillColor)
        }
        
        // draw labels
        
        let px = labelPoint[0]
        let py = labelPoint[1]
        let p = P(CGFloat(px), CGFloat(py))
        b.text(k, p)
    }
    
    let path = "/tmp/out.png"
    
    b.save(path)
}

func bitmap() {
    // let b = BitmapCanvas(32, 32)
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0)
    let b = BitmapCanvas(32, 32, backgroundColor: color)
    
    b.save("/tmp/bitmap.png")
}

func points() {
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0).colorUsingColorSpaceName(NSDeviceRGBColorSpace)
    var b = BitmapCanvas(32, 32, backgroundColor: color)
    
    b[1,1] = NSColor.blackColor()

    b[1,3] = NSColor.redColor()
    b[2,3] = NSColor.greenColor()
    b[3,3] = NSColor.blueColor()
    
    print(NSColor.blueColor())
    print(b[3,3])
    
    b.save("/tmp/bitmap_points.png", open:true)
}

func lines() {
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0)
    let b = BitmapCanvas(32, 32, backgroundColor: color)
    
    b.line(P(1,1), P(10,10))
    
    b.line(P(1,10), P(10,19), color: NSColor.redColor())
    b.lineHorizontal(P(1,21), width: 20)
    b.lineVertical(P(20, 1), height: 19, color: NSColor.blueColor())
    
    b.save("/tmp/bitmap_lines.png")
}

func rects() {
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0)
    let b = BitmapCanvas(32, 32, backgroundColor: color)
    
    b.rectangle(R(5,5,20,10))
    
    b.rectangle(R(10,10,20,10), strokeColor: NSColor.blueColor(), fillColor: NSColor.magentaColor())
    
    b.save("/tmp/bitmap_rects.png")
}

func text() {
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0)
    let b = BitmapCanvas(32, 32, backgroundColor: color)
    
    b.text("hi", P(5,10))
    
    b.text("hello", P(20,30),
        rotationDegrees: -90,
        font: NSFont(name: "Helvetica", size: 10)!,
        color: NSColor.redColor())
    
    b.save("/tmp/bitmap_text.png")
}

func image() {
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0)
    let b = BitmapCanvas(32, 32, backgroundColor: color)
    
    b.image(fromPath:"/usr/share/httpd/icons/sphere2.png", P(0,0))
    
    b.save("/tmp/bitmap_image.png")
}

func bezier() {
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0)
    let b = BitmapCanvas(32, 32, backgroundColor: color)
    
    b.setAllowsAntialiasing(true)
    
    NSColor.orangeColor().setFill()
    
    let bp = NSBezierPath()
    bp.moveToPoint(P(2,2))
    bp.curveToPoint(P(20,14), controlPoint1: P(14,30), controlPoint2: P(15,30))
    bp.curveToPoint(P(32,13), controlPoint1: P(24,14), controlPoint2: P(24,19))
    bp.closePath()
    bp.fill()
    bp.stroke()
    
    b.save("/tmp/bitmap_bezier.png")
}

func cgContext() {
    
    let color = NSColor(deviceWhite: 0.95, alpha: 1.0)
    let b = BitmapCanvas(32, 32, backgroundColor: color)
    
    CGContextAddEllipseInRect(b.cgContext, R(2, 2, 24, 24))
    CGContextStrokePath(b.cgContext)
    
    b.setAllowsAntialiasing(true)
    
    CGContextSetStrokeColorWithColor(b.cgContext, NSColor.blueColor().CGColor)
    CGContextAddEllipseInRect(b.cgContext, R(12, 12, 24, 24))
    CGContextStrokePath(b.cgContext)
    
    b.save("/tmp/bitmap_cgcontext.png")
}

//switzerland()

bitmap()
points()
lines()
rects()
text()
image()
bezier()
cgContext()
