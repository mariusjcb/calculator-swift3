//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Marius Ilie on 22/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import Foundation

final class CalculatorBrain {
    private var accumulator = 0.0
    private var internalProgramLog = [AnyObject]()
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "×" : Operation.BinaryOperation({ $0 * $1  }),
        "÷" : Operation.BinaryOperation({ $0 / $1  }),
        "+" : Operation.BinaryOperation({ $0 + $1  }),
        "−" : Operation.BinaryOperation({ $0 - $1  }),
        "=" : Operation.Equals
    ]
    
    func addUnaryOperation(withSymbol symbol: String, closure operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.UnaryOperation(operation)
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private func executePandingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil;
        }
    }
    
    func setOperand(_ operand: Double) {
        self.accumulator = operand
        internalProgramLog.append(operand as AnyObject);
    }
    
    func performOperation(_ symbol: String) {
        if let operation = operations[symbol]
        {
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
            case .UnaryOperation(let closure):
                accumulator = closure(accumulator)
            case .BinaryOperation(let closure):
                executePandingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: closure, firstOperand: accumulator)
            case .Equals:
                executePandingBinaryOperation()
            }
        }
        internalProgramLog.append(symbol as AnyObject);
    }
    
    typealias PropertyList = AnyObject
    
    var programLog: PropertyList {
        get {
            return internalProgramLog as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgramLog.removeAll()
    }
}
