//
//  ViewController.swift
//  Calculator
//
//  Created by Marius Ilie on 20/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

// filmora

import UIKit

var countVCs = 0

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countVCs += 1
        print("VCs in heap: \(countVCs)")
        
        brain.addUnaryOperation(withSymbol: "🔴√") { [weak weakSelf = self] in
            weakSelf?.display.backgroundColor = UIColor.red
            return sqrt($0)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    deinit {
        countVCs -= 1
        print("VCs in heap: \(countVCs)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTouchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if(userIsInTheMiddleOfTyping)
        {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    lazy var brain = CalculatorBrain();
    @IBAction func performOperation(_ sender: UIButton) {
        if(userIsInTheMiddleOfTyping) {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    @IBAction func save() {
        savedProgram = brain.programLog
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.programLog = savedProgram!
            displayValue = brain.result
        }
    }
    
}

