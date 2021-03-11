//
//  MLView.swift
//  MetalLive
//
//  Created by Gustavo Branco on 3/10/21.
//

import MetalKit

class MLView: MTKView {
  let inputController =  MLInputController()
}

extension MLView: MouseDelegate {
  func mouseEvent(mouse: MouseControl, state: InputState, delta: SIMD3<Float>, location: SIMD2<Float>) {
    print("Location: \(location) State: \(state)")
  }
}

extension MLView: KeyboardDelegate {
  func keyPressed(key: KeyboardControl, state: InputState) -> Bool {
    switch key {
    default:
      print("Presed Key: \(key) State: \(state)")
      break
    }
    return true
  }
}

extension MLView {
  override var acceptsFirstResponder: Bool {
    return true
  }
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
  }
  
  override func keyDown(with event: NSEvent) {
    guard let key = KeyboardControl(rawValue: event.keyCode) else {
      return
    }
    let state: InputState = event.isARepeat ? .continued : .began
    inputController.processEvent(key: key, state: state)
  }
  
  override func keyUp(with event: NSEvent) {
    guard let key = KeyboardControl(rawValue: event.keyCode) else {
      return
    }
    inputController.processEvent(key: key, state: .ended)
  }
    
  override func mouseDown(with event: NSEvent) {
    inputController.processEvent(mouse: .leftDown, state: .began, event: event)
  }
  
  override func mouseUp(with event: NSEvent) {
    inputController.processEvent(mouse: .leftUp, state: .ended, event: event)
  }
  
  override func mouseDragged(with event: NSEvent) {
    inputController.processEvent(mouse: .leftDrag, state: .continued, event: event)
  }
  
  override func rightMouseDown(with event: NSEvent) {
    inputController.processEvent(mouse: .rightDown, state: .began, event: event)
  }
  
  override func rightMouseDragged(with event: NSEvent) {
    inputController.processEvent(mouse: .rightDrag, state: .continued, event: event)
  }
  
  override func rightMouseUp(with event: NSEvent) {
    inputController.processEvent(mouse: .rightUp, state: .ended, event: event)
  }
}


