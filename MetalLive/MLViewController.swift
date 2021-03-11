//
//  ViewController.swift
//  MetalLive
//
//  Created by Gustavo Branco on 3/10/21.
//

import Cocoa
import MetalKit

let device = MTLCreateSystemDefaultDevice()

class MLViewController: NSViewController {
  var metallib: URL
  var fm: MLFileMonitor
  var renderer: MetalToy //In the future these could be other types of renderers
  
  @IBAction func open(_ sender: Any) {
    let panel = NSOpenPanel()

    panel.title = "Select the shader file"
    panel.showsResizeIndicator = true
    panel.showsHiddenFiles = false
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false

    panel.allowedFileTypes = ["metallib"]

    panel.begin { [self] response in
      if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
        if(metallib.absoluteString != fileUrl.absoluteString) {
          do {
            try updateView(fileUrl: fileUrl)
          } catch {
            print("Open failed: \(error.localizedDescription)")
            resetViewToSafeDefault()
          }
        }
      }
    }
  }
  
  @IBAction func pause(_ sender: Any) {
    let aView = self.view as! MLView
    if(aView.isAnimationPaused){
      print("PLAY")
      aView.isAnimationPaused = false
    } else {
      print("PAUSE")
      aView.isAnimationPaused = true
    }
  }
  
  @IBAction func restart(_ sender: Any) {
    print("RESTART")
    renderer.time = 0
  }
    
  private func resetViewToSafeDefault() {
    print("Resetting view to safe defaults.")
    let fileUrl = Bundle.main.url(forResource: "Empty", withExtension: "metallib")!
    do {
      try updateView(fileUrl: fileUrl)
    } catch {
      fatalError(error.localizedDescription)
    }
  }
  
  private func updateView(fileUrl: URL) throws {
    print("Updating view to \(fileUrl.absoluteString)")
    self.metallib = fileUrl
    try renderer.buildPipeline(metallibUrl: fileUrl, device: device!)
    fm = try MLFileMonitor(url: fileUrl)
    fm.delegate = self
    self.view.window?.title = self.metallib.deletingPathExtension().lastPathComponent
  }
  
  required init?(coder: NSCoder) {
    self.metallib = Bundle.main.url(forResource: "HappyJumping", withExtension: "metallib")!
    self.renderer = MetalToy(metallib: self.metallib, device: device!)
    do {
      fm = try MLFileMonitor(url: metallib)
    } catch {
      fatalError(error.localizedDescription)
    }
    super.init(coder: coder)
    fm.delegate = self
  }
  
  override func loadView() {
    let frame = CGRect(x: 0, y: 0, width: 800, height: 450)
    let aView = MLView(frame: frame, device: device)
    aView.delegate = renderer
    aView.preferredFramesPerSecond = 60
    aView.enableSetNeedsDisplay = true
    aView.framebufferOnly = false
    aView.isPaused = false
    aView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
    aView.drawableSize = aView.frame.size
    aView.inputController.keyboardDelegate = aView
    aView.inputController.mouseDelegate = aView
    self.view = aView
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    self.view.window?.title = self.metallib.deletingPathExtension().lastPathComponent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let aView = view as? MLView else {
      fatalError("metal view not set up in storyboard")
    }
    addGestureRecognizers(to: aView)
  }
}

extension MLViewController: FileMonitorDelegate {  
  func didReceive() {
    print("Metallib Changed \(self.metallib.absoluteString)")
    do {
      try self.renderer.buildPipeline(metallibUrl: self.metallib, device: device!)
    } catch {
      resetViewToSafeDefault()
    }
    print("Metallib rebuild")
  }
}

extension MLViewController {
  func addGestureRecognizers(to view: NSView) {
    let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
    view.addGestureRecognizer(pan)
  }
  
  @objc func handlePan(gesture: NSPanGestureRecognizer) {
    let location = gesture.location(in: gesture.view)
    let translation = gesture.translation(in: gesture.view)
    let delta = SIMD2<Float>(Float(translation.x),
                             Float(translation.y))
    renderer.setMouse(location: location)
    gesture.setTranslation(.zero, in: gesture.view)
  }
  
  override func scrollWheel(with event: NSEvent) {
    print("Mouse scroll wheel \(event.deltaY)")
//    renderer?.camera.zoom(delta: Float(event.deltaY))
  }
}

