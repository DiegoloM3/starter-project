import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Draws the images of the app icon and the splash screen in assets/branding, from the Daily News logo of the app
// design: a blue rounded square with the white newspaper glyph (the 24x24 stroke icon of the design, stroke width 1.8,
// round caps and joins). It uses CoreGraphics, so it runs on macOS: `swift tool/render_branding.swift assets/branding`.
let blue = CGColor(red: 0x1E / 255.0, green: 0x6F / 255.0, blue: 0xD9 / 255.0, alpha: 1)
let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)

func glyphPath() -> CGPath {
  let path = CGMutablePath()
  // M4 5h13v14H6a2 2 0 0 1-2-2V5z
  path.move(to: CGPoint(x: 4, y: 5))
  path.addLine(to: CGPoint(x: 17, y: 5))
  path.addLine(to: CGPoint(x: 17, y: 19))
  path.addLine(to: CGPoint(x: 6, y: 19))
  path.addArc(tangent1End: CGPoint(x: 4, y: 19), tangent2End: CGPoint(x: 4, y: 17), radius: 2)
  path.addLine(to: CGPoint(x: 4, y: 5))
  path.closeSubpath()
  // M17 9h3v8a2 2 0 0 1-2 2
  path.move(to: CGPoint(x: 17, y: 9))
  path.addLine(to: CGPoint(x: 20, y: 9))
  path.addLine(to: CGPoint(x: 20, y: 17))
  path.addArc(tangent1End: CGPoint(x: 20, y: 19), tangent2End: CGPoint(x: 18, y: 19), radius: 2)
  // M8 9h5 M8 13h5
  path.move(to: CGPoint(x: 8, y: 9))
  path.addLine(to: CGPoint(x: 13, y: 9))
  path.move(to: CGPoint(x: 8, y: 13))
  path.addLine(to: CGPoint(x: 13, y: 13))
  return path
}

/// Draws the glyph inside a square of side [size] centered in the canvas (the 24x24 box of the icon).
func drawGlyph(_ context: CGContext, canvas: CGFloat, size: CGFloat, color: CGColor) {
  context.saveGState()
  let origin = (canvas - size) / 2
  context.translateBy(x: origin, y: origin)
  context.scaleBy(x: size / 24, y: size / 24)
  context.addPath(glyphPath())
  context.setStrokeColor(color)
  context.setLineWidth(1.8)
  context.setLineCap(.round)
  context.setLineJoin(.round)
  context.strokePath()
  context.restoreGState()
}

func drawRoundedSquare(_ context: CGContext, canvas: CGFloat, size: CGFloat, radius: CGFloat) {
  let origin = (canvas - size) / 2
  let rect = CGRect(x: origin, y: origin, width: size, height: size)
  context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
  context.setFillColor(blue)
  context.fillPath()
}

func render(_ name: String, canvas: Int, draw: (CGContext, CGFloat) -> Void) {
  let space = CGColorSpace(name: CGColorSpace.sRGB)!
  let context = CGContext(data: nil, width: canvas, height: canvas, bitsPerComponent: 8, bytesPerRow: 0,
                          space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  // SVG coordinates grow downwards.
  context.translateBy(x: 0, y: CGFloat(canvas))
  context.scaleBy(x: 1, y: -1)
  draw(context, CGFloat(canvas))
  let url = URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent(name)
  let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(destination, context.makeImage()!, nil)
  CGImageDestinationFinalize(destination)
  print("wrote \(name) \(canvas)x\(canvas)")
}

// Launcher icon for old Android versions: the whole rounded square (radius 40/176 of the design).
render("app_icon.png", canvas: 1024) { context, canvas in
  drawRoundedSquare(context, canvas: canvas, size: canvas, radius: canvas * 40 / 176)
  drawGlyph(context, canvas: canvas, size: canvas * 0.48, color: white)
}
// Adaptive icon: the phone draws the blue background and its own shape; the glyph takes half of the
// 72 dp that stay visible of the 108 dp canvas.
render("app_icon_foreground.png", canvas: 1024) { context, canvas in
  drawGlyph(context, canvas: canvas, size: canvas * 36 / 108, color: white)
}
// Themed icon (Android 13+): only the shape of the glyph is used, in the colors of the phone.
render("app_icon_monochrome.png", canvas: 1024) { context, canvas in
  drawGlyph(context, canvas: canvas, size: canvas * 36 / 108, color: white)
}
// Splash before Android 12: the logo at 104 dp, drawn for xxxhdpi (4x).
render("splash_logo.png", canvas: 416) { context, canvas in
  drawRoundedSquare(context, canvas: canvas, size: canvas, radius: canvas * 30 / 104)
  drawGlyph(context, canvas: canvas, size: canvas * 0.5, color: white)
}
// Splash from Android 12: 960 px (240 dp) with the logo inside the 640 px circle that stays visible.
render("splash_logo_android12.png", canvas: 960) { context, canvas in
  drawRoundedSquare(context, canvas: canvas, size: 416, radius: 120)
  drawGlyph(context, canvas: canvas, size: 208, color: white)
}
