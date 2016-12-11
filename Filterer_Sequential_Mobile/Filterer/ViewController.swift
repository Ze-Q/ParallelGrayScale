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
    let image = UIImage(named: "90")
    
    @IBAction func onConvertButtonPressed(sender: UIButton) {
        var imageToProcess = RGBAImage(image: image!)!
        let timeAtPress = NSDate()
        
        for y in 0..<imageToProcess.height {
            for x in 0..<imageToProcess.width {
                let index = y*imageToProcess.width+x
                var pixel = imageToProcess.pixels[index]
                let average = UInt8( (Int(pixel.red) + Int(pixel.green) + Int(pixel.blue))/3 )
                
                pixel.red = average
                pixel.green = average
                pixel.blue = average
                imageToProcess.pixels[index] = pixel
            }
        }
        
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

