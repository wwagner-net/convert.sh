#!/usr/bin/env swift
/// Generates the WebM Converter app icon as a PNG at the requested pixel size.
/// Usage:  swift create-icon.swift <size> <output.png>

import AppKit
import CoreGraphics

let args = CommandLine.arguments
guard args.count == 3, let sizeD = Double(args[1]) else {
    fputs("Usage: swift create-icon.swift <size> <output.png>\n", stderr)
    exit(1)
}
let size = CGFloat(sizeD)
let outputPath = args[2]

// ─────────────────────────────────────────────────────────────────────────────
//  Draw the icon into an off-screen NSImage
// ─────────────────────────────────────────────────────────────────────────────

let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

guard let ctx = NSGraphicsContext.current?.cgContext else { exit(1) }
ctx.saveGState()

let r = CGRect(origin: .zero, size: CGSize(width: size, height: size))

// ── 1. Background: deep dark purple ────────────────────────────────────────
let bgPath = CGPath(roundedRect: r,
                    cornerWidth:  size * 0.22,
                    cornerHeight: size * 0.22,
                    transform:    nil)
ctx.addPath(bgPath)
ctx.clip()

let bgColors = [
    CGColor(red: 0.11, green: 0.07, blue: 0.25, alpha: 1.0),
    CGColor(red: 0.04, green: 0.02, blue: 0.12, alpha: 1.0)
] as CFArray
let bgGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                        colors: bgColors,
                        locations: [0, 1])!
ctx.drawLinearGradient(bgGrad,
                       start: CGPoint(x: 0, y: size),
                       end:   CGPoint(x: size, y: 0),
                       options: [])

// ── 2. Film strip bands ─────────────────────────────────────────────────────
let bandH = size * 0.145
let filmBandColor = CGColor(red: 0.17, green: 0.11, blue: 0.37, alpha: 1.0)

// Top band
ctx.setFillColor(filmBandColor)
ctx.fill(CGRect(x: 0, y: size - bandH, width: size, height: bandH))

// Bottom band
ctx.fill(CGRect(x: 0, y: 0, width: size, height: bandH))

// Separator lines
ctx.setFillColor(CGColor(red: 0.29, green: 0.18, blue: 0.63, alpha: 0.7))
ctx.fill(CGRect(x: 0, y: size - bandH - 2, width: size, height: 2))
ctx.fill(CGRect(x: 0, y: bandH,            width: size, height: 2))

// Sprocket holes (9 holes per strip)
let holeR      = size * 0.027
let holeCY_top = size - bandH * 0.5
let holeCY_bot = bandH * 0.5
let holeSpacing = size / 9.0
let holeColor   = CGColor(red: 0.04, green: 0.02, blue: 0.12, alpha: 1.0)

ctx.setFillColor(holeColor)
for i in 0..<9 {
    let cx = holeSpacing * 0.5 + CGFloat(i) * holeSpacing
    ctx.fillEllipse(in: CGRect(x: cx - holeR, y: holeCY_top - holeR,
                               width: holeR*2, height: holeR*2))
    ctx.fillEllipse(in: CGRect(x: cx - holeR, y: holeCY_bot - holeR,
                               width: holeR*2, height: holeR*2))
}

// ── 3. Ambient glow behind play button ─────────────────────────────────────
let glowColors = [
    CGColor(red: 0.42, green: 0.18, blue: 0.80, alpha: 0.30),
    CGColor(red: 0.42, green: 0.18, blue: 0.80, alpha: 0.00)
] as CFArray
let glowGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: glowColors,
                          locations: [0, 1])!
ctx.drawRadialGradient(glowGrad,
                       startCenter: CGPoint(x: size*0.5, y: size*0.5), startRadius: 0,
                       endCenter:   CGPoint(x: size*0.5, y: size*0.5), endRadius: size*0.45,
                       options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

// ── 4. Play-button circle ───────────────────────────────────────────────────
let playColors = [
    CGColor(red: 0.69, green: 0.43, blue: 1.00, alpha: 1.0),
    CGColor(red: 0.18, green: 0.61, blue: 1.00, alpha: 1.0)
] as CFArray
let playGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: playColors,
                          locations: [0, 1])!

let circleR  = size * 0.245
let cx = size * 0.5
let cy = size * 0.5

// Thin outline ring
ctx.setStrokeColor(CGColor(red: 0.69, green: 0.43, blue: 1.0, alpha: 0.40))
ctx.setLineWidth(size * 0.005)
ctx.strokeEllipse(in: CGRect(x: cx-circleR, y: cy-circleR,
                             width: circleR*2, height: circleR*2))

// ── 5. Play triangle ────────────────────────────────────────────────────────
let triLeft  = cx - size * 0.10
let triTop   = cy + size * 0.165
let triBot   = cy - size * 0.165
let triRight = cx + size * 0.23

let tri = CGMutablePath()
tri.move(to:    CGPoint(x: triLeft,  y: triTop))
tri.addLine(to: CGPoint(x: triLeft,  y: triBot))
tri.addLine(to: CGPoint(x: triRight, y: cy))
tri.closeSubpath()

ctx.saveGState()
ctx.addPath(tri)
ctx.clip()
ctx.drawLinearGradient(playGrad,
                       start: CGPoint(x: triLeft,  y: triTop),
                       end:   CGPoint(x: triRight, y: triBot),
                       options: [])
ctx.restoreGState()

// Soft white edge highlight on triangle
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.18))
ctx.setLineWidth(size * 0.003)
ctx.addPath(tri)
ctx.strokePath()

// ── 6. WebM badge pill ──────────────────────────────────────────────────────
let badgeW  = size * 0.375
let badgeH  = size * 0.075
let badgeX  = cx - badgeW * 0.5
let badgeY  = cy - size * 0.38
let badgeR  = badgeH * 0.5

let badgePath = CGPath(roundedRect: CGRect(x: badgeX, y: badgeY,
                                           width: badgeW, height: badgeH),
                       cornerWidth: badgeR, cornerHeight: badgeR, transform: nil)
ctx.saveGState()
ctx.addPath(badgePath)
ctx.clip()
ctx.drawLinearGradient(playGrad,
                       start: CGPoint(x: badgeX,          y: badgeY + badgeH),
                       end:   CGPoint(x: badgeX + badgeW, y: badgeY),
                       options: [])
ctx.restoreGState()

// Highlight shine on badge
ctx.saveGState()
ctx.addPath(badgePath)
ctx.clip()
let shineColors = [
    CGColor(red: 1, green: 1, blue: 1, alpha: 0.15),
    CGColor(red: 1, green: 1, blue: 1, alpha: 0.0)
] as CFArray
let shineGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: shineColors, locations: [0, 1])!
ctx.drawLinearGradient(shineGrad,
                       start: CGPoint(x: badgeX, y: badgeY + badgeH),
                       end:   CGPoint(x: badgeX, y: badgeY + badgeH * 0.5),
                       options: [])
ctx.restoreGState()

// "WebM" text on badge
ctx.restoreGState()

let paraStyle = NSMutableParagraphStyle()
paraStyle.alignment = .center
let fontSize = size * 0.066
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.boldSystemFont(ofSize: fontSize),
    .foregroundColor: NSColor.white,
    .paragraphStyle: paraStyle
]
let text = "WebM" as NSString
let textRect = NSRect(x: badgeX, y: badgeY + (badgeH - fontSize*1.1)*0.5,
                      width: badgeW, height: fontSize * 1.4)
text.draw(in: textRect, withAttributes: attrs)

img.unlockFocus()

// ─────────────────────────────────────────────────────────────────────────────
//  Export as PNG
// ─────────────────────────────────────────────────────────────────────────────
guard let tiff = img.tiffRepresentation,
      let rep  = NSBitmapImageRep(data: tiff),
      let png  = rep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
    fputs("Failed to create PNG\n", stderr)
    exit(1)
}

do {
    try png.write(to: URL(fileURLWithPath: outputPath))
    print("✓  \(Int(size))×\(Int(size)) → \(outputPath)")
} catch {
    fputs("Write error: \(error)\n", stderr)
    exit(1)
}
