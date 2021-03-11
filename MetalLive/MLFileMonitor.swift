//
//  FileMonitor.swift
//  MetalLive
//
//  Created by Gustavo Branco on 3/10/21.
//

import Foundation

protocol FileMonitorDelegate: AnyObject {
  func didReceive()
}

final class MLFileMonitor {
    
  let source: DispatchSourceFileSystemObject
  weak var delegate: FileMonitorDelegate?
  
  init(url: URL) throws {
    let path = url.absoluteString.replacingOccurrences(of: "file://", with: "")
    let fileDescriptor = open(path, O_RDONLY)
    
    source = DispatchSource.makeFileSystemObjectSource(
      fileDescriptor: fileDescriptor,
      eventMask: .all,
      queue: DispatchQueue.main
    )
    
    source.setEventHandler {
      self.process(event: self.source.data)
    }
    
    source.setCancelHandler {
      print("Cancel")
    }
    
    source.resume()
  }
  
  deinit {
    source.cancel()
  }
  
  func process(event: DispatchSource.FileSystemEvent) {
    print("Metallib Changed: \(event.rawValue)")
    if(event.rawValue == 6 || event.rawValue == 2) {
      self.delegate?.didReceive()
    }
  }
}
