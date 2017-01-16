//
//  ViewController.swift
//  Spirit level -- RubberDuck
//  
//  suppose the phone is a container with half water inside, water flows as phone rotating, the screen will
//  show how water change based on user's rotation of phone
//  user also can move duck when they touching it
//
//  Created by Lu Han lxh152130 on 4/6/16.
//  Copyright © 2016 新妻英二. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    //get accelerometer parameters
    var motionManager = CMMotionManager()
    
    var blueSquare: UIView?
    var duck_front: UIImageView?
    var duck_side: UIImageView?
    
    //parameters for calculating x,y,z angle of rotation
    var accXYAngle: Double!
    var accXZAngle: Double!
    var accYZAngle: Double!
    var rotAngle: Double!
    
    var accX: Double?
    var accY: Double?
    var accZ: Double?
    
    //position of blueSqaure, two duck images
    var location: CGPoint?
    var duck_side_location: CGPoint?
    var duck_front_location: CGPoint?
    
    //contant of screen size
    let screenSize = UIScreen.mainScreen().bounds
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var radius: CGFloat!
    
    var plain: Bool?
    var touching = false
    var touch: UITouch!
    
    @IBOutlet weak var rotateLabel: UILabel!
    
    //load view
    override func viewDidLoad() {
        
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        radius = sqrt(pow(screenWidth,2)+pow(screenHeight,2))/2
        print("Radius = \(radius)")
        
        //set Motion Manager properties (in seconds)
        motionManager.accelerometerUpdateInterval = 0.2
        
        //Start recording data (swift2 make this more concise than before)
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            accelerometerData, error in
            self.outputAccelerometerData(accelerometerData!.acceleration)
            if(error != nil){
                print("\(error)")
            }
        }

        location = CGPoint(x: screenWidth/2, y: screenHeight/2)
        
        drawSquare(screenWidth, height: screenHeight)
        addDuck()
        
        super.viewDidLoad()
    }
    
    //the follow three functions let duck moves when touching and holding it, and let go when release
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first {
            if plain != nil{
                touching = true
                if plain == true {
                    duck_front_location = touch.locationInView(self.view)
                }else{
                    duck_side_location = touch.locationInView(self.view)
                }
            }
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first {
            if plain != nil{
                touching = true
                if plain == true {
                    duck_front?.center = touch.locationInView(self.view)
                    print("\(duck_front_location)")
                }else{
                    duck_side?.center = touch.locationInView(self.view)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        touching = false
    }
    
    //in rotating number/square format
    func outputAccelerometerData(acceleration: CMAcceleration){
        
        let x = acceleration.x
        let y = acceleration.y
        let z = acceleration.z
        
        accX = x
        accY = y
        accZ = z
        
        //from arctan angle to 360 degree format
        accXYAngle = atan2(x, y)
        let accInXYDegree: Double = accXYAngle * 180 / M_PI
        let xyDegree: Int = Int (accInXYDegree)
        
        accXZAngle = atan2(x, z)
        let accInXZDegree: Double = accXZAngle * 180 / M_PI
        let xzDegree: Int = Int (accInXZDegree)
        
        accYZAngle = atan2(y, z)
        let accInYZDegree: Double = accYZAngle * 180 / M_PI
        let yzDegree: Int = Int (accInYZDegree)
        
        let chosenDegree: Int = chooseDegree(x, y: y, z: z, xyDegree: xyDegree, xzDegree: xzDegree, yzDegree: yzDegree)
        
        let labelRotation = CGFloat(accXYAngle + M_PI)
        rotateLabel.text = "\(chosenDegree)"
        rotateLabel.transform = CGAffineTransformMakeRotation(labelRotation)
        
        //give square rotation and center information + duck positioin
        setCenter()
        blueSquare?.transform = CGAffineTransformMakeRotation(labelRotation)
        blueSquare?.center = location!
        duck_side?.transform = CGAffineTransformMakeRotation(labelRotation)
        duck_front?.transform = CGAffineTransformMakeRotation(labelRotation)

    }
    
    //add rubber duck to the screen
    func addDuck(){
    
        let front = UIImage(named: "duck_front.png")
        let side = UIImage(named: "duck_side.png")
        duck_front = UIImageView(image: front)
        duck_side = UIImageView(image: side)
        duck_front?.alpha = 0.8
        duck_side?.alpha = 0.8
        self.view.addSubview(duck_front!)
        self.view.addSubview(duck_side!)
        
    }
    
    //draw rotating square
    func drawSquare(width: CGFloat, height: CGFloat){
        
        let rect = CGRectMake(0, 0, 2*radius, 2*radius)
        blueSquare = UIView(frame:rect)
        blueSquare?.backgroundColor = UIColor(red: 0.4, green: 0.85, blue: 1, alpha: 1) //water blue
        blueSquare?.alpha = 0.5
        self.view.addSubview(blueSquare!)
        self.view.bringSubviewToFront(blueSquare!)
    }
    
    //decide where is the center of the sqaure
    func setCenter(){
    
       //center of square
        var centerX: Double!
        var centerY: Double!
        
       //center of side_duck
        var duck_centerX: Double!
        var duck_centerY: Double!
        
       //center of front_duck
        var duck_positionX: Double!
        var duck_positionY: Double!
        
        let halfW = Double(screenWidth/2)
        let halfH = Double(screenHeight/2)
        
        //calculate square and duck position
        if let x = accX, let y = accY, let z = accZ{
            
            let r = Double(radius) * (1 - abs(z))
            var k: Double!
            if y == 0 {
                k = 1
            }else{
                k = abs(x / y)
            }
            let sk =  sqrt(pow(k,2)+1)
            let offX = k * r / sk
            let offY = r / sk
            let duck_offX = k * Double(radius) / sk
            let duck_offY = Double(radius) / sk
            
            let sqr2 = sqrt(2.0)
            let c = (2 + sqr2) * (1 - abs(z))
            let duckX = abs(x) * c * halfW
            let duckY = abs(y) * c * halfH
            
            if x == 0{
            
                centerX = halfW
                centerY = halfH - r * y
                duck_centerX = halfW
                duck_centerY = halfH * y
                duck_positionX = duck_centerX
                duck_positionY = duck_centerY
                
            }else if y == 0{
            
                centerX = halfW - r * x
                centerY = halfH
                duck_centerX = halfW * x
                duck_centerY = halfH
                duck_positionX = duck_centerX
                duck_positionY = duck_centerY
                
            }else if x > 0 && y > 0{
            
                centerX = halfW + offX
                centerY = halfH - offY
                duck_centerX = centerX - duck_offX
                duck_centerY = centerY + duck_offY
                duck_positionX = halfW - duckX
                duck_positionY = halfH + duckY
                
            }else if x > 0 && y < 0{
                
                centerX = halfW + offX
                centerY = halfH + offY
                duck_centerX = centerX - duck_offX
                duck_centerY = centerY - duck_offY
                duck_positionX = halfW - duckX
                duck_positionY = halfH - duckY
            
            }else if x < 0 && y > 0{
                
                centerX = halfW - offX
                centerY = halfH - offY
                duck_centerX = centerX + duck_offX
                duck_centerY = centerY + duck_offY
                duck_positionX = halfW + duckX
                duck_positionY = halfH + duckY
            
            }else if x < 0 && y < 0{
                
                centerX = halfW - offX
                centerY = halfH + offY
                duck_centerX = centerX + duck_offX
                duck_centerY = centerY - duck_offY
                duck_positionX = halfW + duckX
                duck_positionY = halfH - duckY
            }
            
            location = CGPoint(x: CGFloat(centerX), y: CGFloat(centerY))
            duck_side_location = CGPoint(x: CGFloat(duck_centerX), y: CGFloat(duck_centerY))
            duck_front_location = CGPoint(x: CGFloat(duck_positionX), y: CGFloat(duck_positionY))
        }
        
        if plain != nil && touching == false{
            if plain == true {
                duck_side?.center = CGPoint(x: -100, y: -100)
                duck_front?.center = duck_front_location!
            }else{
                duck_front?.center = CGPoint(x: -100, y: -100)
                duck_side?.center = duck_side_location!
            }
        }
    }

    //Choose to show vertical degree or plain degree
    func chooseDegree(x: Double, y: Double, z: Double, xyDegree: Int, xzDegree: Int, yzDegree: Int)-> Int{

        var chosenDegree: Int = 0
        
        let yz = yzToScale(yzDegree)
        let xz = xzToScale(xzDegree)
        let xy = xyToScale(xyDegree)
        
        if z != 0 && x/z < 1 && x/z > -1 && y/z > -1 && y/z < 1  {
            //more plain
            if abs(yz) > abs(xz) {
                chosenDegree = yz - 1
            }else {
                chosenDegree = xz - 1
            }
            plain = true
        }else {
            //more vertical
            plain = false
            chosenDegree = xy
        }

        return abs(chosenDegree)
    }
    
    //the follow three functions scale -180~180 to -90~90
    func xyToScale(xyDegree: Int)-> Int{
        
        var scaledDegree: Int = 0;
        
        if xyDegree <= -135 {
            scaledDegree = -xyDegree - 180
        }
        else if xyDegree <= -45 {
            scaledDegree = xyDegree + 90
        }
        else if xyDegree <= 45 {
            scaledDegree = -xyDegree
        }
        else if xyDegree <= 135 {
            scaledDegree = xyDegree - 90 + 1
        }
        else {
            scaledDegree = -xyDegree + 180 - 1
        }
        
        return scaledDegree
    }
    
    func yzToScale(yzDegree: Int)-> Int{
        
        var scaledDegree: Int = 0
        
        if yzDegree > -45 && yzDegree < 0 {
            scaledDegree = yzDegree
        }
        else if yzDegree < 45 && yzDegree > 0 {
            scaledDegree = -yzDegree
        }
        else if yzDegree > 135 {
            scaledDegree = 180 - yzDegree
        }
        else if yzDegree < -135 {
            scaledDegree = yzDegree + 180
        }
        
        return scaledDegree
    }
    
    func xzToScale(xzDegree: Int)-> Int{
        
        var scaledDegree: Int = 0
        
        if xzDegree > -45 && xzDegree < 0{
            scaledDegree = xzDegree
        }
        else if xzDegree < 45 && xzDegree > 0{
            scaledDegree = -xzDegree
        }
        else if xzDegree > 135 {
            scaledDegree = 180 - xzDegree
        }
        else if xzDegree < -135 {
            scaledDegree = xzDegree + 180
        }
        
        return scaledDegree
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

