//
//  ViewController.swift
//  Filterer_Metal
//
//  Created by Ze Qian Zhang on 2016-11-27.
//  Copyright © 2016 zexception. All rights reserved.
//

import UIKit
import Metal
import MetalKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var resultText: UITextField!
    
    @IBAction func onConvertButtonPressed(sender: AnyObject) {
        dispatch_async(queue) { () -> Void in
            let timeAtPress = NSDate()
            self.importTexture()
            self.applyFilter()
            let finalResult = self.imageFromTexture(self.outTexture)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageView.image = finalResult
                let elapsed = NSDate().timeIntervalSinceDate(timeAtPress)
                self.resultText.text = (String(format:"%f", elapsed))
            })
            
        }
    }
    var pixelSize: UInt = 10
    
    let queue = dispatch_queue_create("com.zexception.metal", DISPATCH_QUEUE_SERIAL)
    lazy var device: MTLDevice! = { MTLCreateSystemDefaultDevice() }()
    lazy var defaultLibrary: MTLLibrary! = { self.device.newDefaultLibrary() }()
    lazy var commandQueue: MTLCommandQueue! = {
        NSLog("\(self.device.name!)")
        return self.device.newCommandQueue()
    }()
    
    var inTexture: MTLTexture!
    var outTexture: MTLTexture!
    let bytesPerPixel: Int = 4
    
    /// A Metal compute pipeline state
    var pipelineState: MTLComputePipelineState!
    
    func setUpMetal() {
        if let kernelFunction = defaultLibrary.newFunctionWithName("grayscale") {
            do {
                pipelineState = try device.newComputePipelineStateWithFunction(kernelFunction)
            }
            catch {
                fatalError("Impossible to setup Metal")
            }
        }
    }
    
    let threadGroupCount = MTLSizeMake(16, 16, 1)
    lazy var threadGroups: MTLSize = {
        MTLSizeMake(Int(self.inTexture.width) / self.threadGroupCount.width, Int(self.inTexture.height) / self.threadGroupCount.height, 1)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(queue) {
            self.setUpMetal()
            print("The width is ", self.pipelineState.threadExecutionWidth)
            print("The max total is ", self.pipelineState.maxTotalThreadsPerThreadgroup)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func importTexture() {
        guard let image = UIImage(named: "90") else {
            fatalError("Can't read image")
        }
        inTexture = textureFromImage(image)
    }
    
    func applyFilter() {
        
        let commandBuffer = commandQueue.commandBuffer()
        let commandEncoder = commandBuffer.computeCommandEncoder()
        
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(inTexture, atIndex: 0)
        commandEncoder.setTexture(outTexture, atIndex: 1)
        
        let buffer = device.newBufferWithBytes(&pixelSize, length: sizeof(UInt), options: [MTLResourceOptions.StorageModeShared])
        commandEncoder.setBuffer(buffer, offset: 0, atIndex: 0)
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func textureFromImage(image: UIImage) -> MTLTexture {
        
        guard let cgImage = image.CGImage else {
            fatalError("Can't open image \(image)")
        }
        
        let textureLoader = MTKTextureLoader(device: self.device)
        do {
            let textureOut = try textureLoader.newTextureWithCGImage(cgImage, options: nil)
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(textureOut.pixelFormat, width: textureOut.width, height: textureOut.height, mipmapped: false)
            outTexture = self.device.newTextureWithDescriptor(textureDescriptor)
            return textureOut
        }
        catch {
            fatalError("Can't load texture")
        }
    }
    
    
    func imageFromTexture(texture: MTLTexture) -> UIImage {
        
        let imageByteCount = texture.width * texture.height * bytesPerPixel
        let bytesPerRow = texture.width * bytesPerPixel
        var src = [UInt8](count: Int(imageByteCount), repeatedValue: 0)
        
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        texture.getBytes(&src, bytesPerRow: bytesPerRow, fromRegion: region, mipmapLevel: 0)
        
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue))
        
        let grayColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        let context = CGBitmapContextCreate(&src, texture.width, texture.height, bitsPerComponent, bytesPerRow, grayColorSpace, bitmapInfo.rawValue);
        
        let dstImageFilter = CGBitmapContextCreateImage(context!);
        
        return UIImage(CGImage: dstImageFilter!, scale: 0.0, orientation: UIImageOrientation.Up)
    }
}

