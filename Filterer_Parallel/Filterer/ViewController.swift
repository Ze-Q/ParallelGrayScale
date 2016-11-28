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
    

    
    func update(start: Int, end: Int, tag: String, inout image: RGBAImage, completion: (() -> Void)!) {
        for y in start..<end {
            for x in 0..<image.width {
                let index = y*image.width+x
                var pixel = image.pixels[index]
                let average = UInt8((Int(pixel.red) + Int(pixel.green) + Int(pixel.blue))/3)
                pixel.red = average
                pixel.green = average
                pixel.blue = average
                image.pixels[index] = pixel
            }
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
        var imageToProcess2 = RGBAImage(image: image!)!
        imageToProcess.pixels = Array(imageToProcess.pixels.dropLast(imageToProcess.height*imageToProcess.width/2))
        imageToProcess2.pixels = Array(imageToProcess2.pixels.dropFirst(imageToProcess.height*imageToProcess.width/2))
        let timeAtPress = NSDate()
        let queue = dispatch_queue_create("cqueue.hoffman.jon", DISPATCH_QUEUE_CONCURRENT)
        var count = 0
        var count1 = 0
        dispatch_async (queue) {
            self.update(0, end: imageToProcess.height, tag: "async0", image: &imageToProcess, completion: {
                count = 1
            })

        }
 
        
        dispatch_async(queue) {
            self.update(0, end: imageToProcess2.height, tag: "async1", image: &imageToProcess2, completion: {
                count1 = 1
            })
        }
        


        while((count+count1) < 2) {
            
        }
 
        imageToProcess.pixels.appendContentsOf(imageToProcess2.pixels)
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

