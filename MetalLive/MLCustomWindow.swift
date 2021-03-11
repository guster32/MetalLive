//
//  CustomWindow.swift
//  MetalViewer
//
//  Created by Gustavo Branco on 3/9/21.
//

import Cocoa
import Foundation

class CustomWindow: NSWindowController {
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    shouldCascadeWindows = true
  }
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    self.configureWindowAppearance()
  }
  
  private func configureWindowAppearance() {
    if let window = window {
      if let view = window.contentView {
        view.wantsLayer = true
      }
    }
  }
}
