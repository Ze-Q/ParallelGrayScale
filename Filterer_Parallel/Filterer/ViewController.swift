//
//  ViewController.swift
//  Filterer
//
//  Created by Ze Qian Zhang on 2016-11-27.
//  Copyright © 2016 zexception. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var convertButton: UIButton!
    @IBOutlet var resultText: UITextField!
    let image = UIImage(named: "test")
    

    
    func update(start: Int, end: Int, tag: String, image: RGBAImage, inout pixels: [Pixel], completion: (() -> Void)!) {
        for y in start..<end {
                var pixel = image.pixels[y]
                let average = UInt8((Int(pixel.red) + Int(pixel.green) + Int(pixel.blue))/3)
                pixel.red = average
                pixel.green = average
                pixel.blue = average
                pixels.append(pixel)
            }

        completion()
    }
    
    
    func update(start: Int, end: Int, inout image: RGBAImage, image2: RGBAImage) {
        for y in start..<end {
            for x in 0..<image.width {
                let index = y*image.width+x
                image.pixels[index] = image2.pixels[index]
            }
        }
    }
    
    @IBAction func onConvertButtonPressed(sender: UIButton) {
        var imageToProcess = RGBAImage(image: image!)!
        let timeAtPress = NSDate()
        var pixel1 = [Pixel]()
        var pixel2 = [Pixel]()
        var pixel3 = [Pixel]()
        var pixel4 = [Pixel]()
        let queue = dispatch_queue_create("cqueue.hoffman.jon", DISPATCH_QUEUE_CONCURRENT)
        var count = 0
        /*
        dispatch_apply(imageToProcess.pixels.count, queue) {
            (i: Int) -> Void in
                var pixel = imageToProcess.pixels[i]
                let average = UInt8((Int(pixel.red) + Int(pixel.green) + Int(pixel.blue))/3)
                pixel.red = average
                pixel.green = average
                pixel.blue = average
                imageToProcess.pixels[i] = pixel
        }
        */
        
        let slice = imageToProcess.pixels.count/4
        dispatch_async (queue) {
            self.update(0, end: slice, tag: "async0", image: imageToProcess, pixels: &pixel1, completion: {
                count += 1
            })

        }
 
        
        dispatch_async(queue) {
            self.update(slice, end: slice*2, tag: "async1", image: imageToProcess, pixels: &pixel2, completion: {
                count += 1
            })
        }
        
        dispatch_async(queue) {
            self.update(slice*2, end: slice*3, tag: "async2", image: imageToProcess, pixels: &pixel3, completion: {
                count += 1
            })
        }
        
        dispatch_async(queue) {
            self.update(slice*3, end: imageToProcess.pixels.count, tag: "async3", image: imageToProcess, pixels: &pixel4, completion: {
                count += 1
            })
        }
        


        while((count) < 4) {
            
        }
        
        
        imageToProcess.pixels.removeAll(keepCapacity: true)
        imageToProcess.pixels.appendContentsOf(pixel1)
        imageToProcess.pixels.appendContentsOf(pixel2)
        imageToProcess.pixels.appendContentsOf(pixel3)
        imageToProcess.pixels.appendContentsOf(pixel4)
        let result = imageToProcess.toUIImage()
        let elapsed = NSDate().timeIntervalSinceDate(timeAtPress)
        resultText.text = (String(format:"%f", elapsed))
        imageView.image = result
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

