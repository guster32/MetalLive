//
//  MetalToy.swift
//  MetalLive
//
//  Created by Gustavo Branco on 3/10/21.
//

import MetalKit
import Dispatch

protocol MLError: LocalizedError {

    var title: String? { get }
    var code: Int { get }
}

struct FunctionNotFound: MLError {
  var title: String?
   var code: Int
   var errorDescription: String? { return _description }
   var failureReason: String? { return _description }

   private var _description: String

   init(title: String?, description: String, code: Int) {
       self.title = title ?? "Error"
       self._description = description
       self.code = code
   }
}


class MetalToy: NSObject {
  var queue: MTLCommandQueue!
  var pipelineState: MTLComputePipelineState!
  var time: Float = 0
  var mouse: SIMD2<Float>
  let ENTRY_KERNEL_FUNCTION = "metaltoy"
    
  public init(metallib: URL, device:MTLDevice) {
    self.mouse = SIMD2<Float>(repeating: 0.0)
    queue = device.makeCommandQueue()
    super.init()
    do {
      try self.buildPipeline(metallibUrl: metallib, device: device)
    } catch {
      fatalError(error.localizedDescription)
    }
    
  }
  
  public func setMouse(location:NSPoint) {
    self.mouse = SIMD2<Float>(Float(location.x), Float(location.y))
  }
  
  public func buildPipeline(metallibUrl:URL, device:MTLDevice) throws {
    queue = device.makeCommandQueue()
    let fileHandle = try FileHandle(forReadingFrom: metallibUrl)
    let newData = fileHandle.readDataToEndOfFile()
    let dataa = newData.withUnsafeBytes {
      DispatchData(bytes: UnsafeRawBufferPointer(start: $0, count: newData.count))
    }
    let library = try device.makeLibrary(data:dataa as __DispatchData)
    guard let kernelFunction = library.makeFunction(name: ENTRY_KERNEL_FUNCTION) else { throw FunctionNotFound (title: "FunctionNotFound", description: "\(ENTRY_KERNEL_FUNCTION) not found on metallib \(metallibUrl.absoluteString)", code: -1) }
    self.pipelineState = try device.makeComputePipelineState(function:kernelFunction)
  }
  
}

extension MetalToy: MTKViewDelegate {
  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
  
  public func draw(in view: MTKView) {
    time += 0.01
    guard let commandBuffer = queue.makeCommandBuffer(),
          let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
          let drawable = view.currentDrawable else { fatalError() }
    commandEncoder.setComputePipelineState(pipelineState)
    commandEncoder.setTexture(drawable.texture, index: 0)
    commandEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 0)
    commandEncoder.setBytes(&mouse, length: MemoryLayout<Float>.size*2, index: 1)
    let w = pipelineState.threadExecutionWidth
    let h = pipelineState.maxTotalThreadsPerThreadgroup / w
    let threadsPerGroup = MTLSizeMake(w, h, 1)
    let threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width),
                                     Int(view.drawableSize.height), 1)
    commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
    commandEncoder.endEncoding()
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
