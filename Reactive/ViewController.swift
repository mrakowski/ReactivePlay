//
//  ViewController.swift
//  Reactive
//
//  Created by Michael Rakowski on 12/23/16.
//  Copyright © 2016 RRR. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    func sectionStr(sectionName :String) -> String
    {
        let secStrLen = sectionName.lengthOfBytes(using: String.Encoding.utf8)
        let dividerStr = String( [Character](repeating: "-", count:secStrLen))
        return ("\n" + dividerStr + "\n" + sectionName + "\n" + dividerStr + "\n")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapFilterEx()

        self.signalsEx()
        
    }
    
    // MARK:
    
    func mapFilterEx() {
    
        // Transforming - Map
        var buffer :String
        buffer = sectionStr(sectionName: "Transforming - map")
        let (mapSignal, mapObserver) = Signal<Int, NoError>.pipe()
        let signalMultiplied = mapSignal.map { number in
            return number * 10
        }
        signalMultiplied.observeValues { next in
            buffer = buffer + String(next) + "\n"
        }
        mapObserver.send(value: 1)
        mapObserver.send(value: 2)
        mapObserver.send(value: 3)
        print(buffer)
        
        
        // Transforming - Filter
        buffer = sectionStr(sectionName: "Transforming - filter")
        let (filterSignal, filterObserver) = Signal<Int, NoError>.pipe()
        filterSignal
            .filter { number in number > 10 }
            .observeValues { filteredVal in buffer = buffer + String(filteredVal) + "\n" }
        filterObserver.send(value: 2)
        filterObserver.send(value: 30)
        filterObserver.send(value: 22)
        filterObserver.send(value: 5)
        filterObserver.send(value: 60)
        filterObserver.send(value: 1)
        print(buffer)
        
        //
        buffer = sectionStr(sectionName: "Aggregating - collect")
        let (collectSignal, collectObserver) = Signal<Int, NoError>.pipe()
        collectSignal
            .collect()
            .observeValues { collected in buffer = buffer + String(describing: collected) + "\n" }
        collectObserver.send(value: 1)
        collectObserver.send(value: 2)
        collectObserver.send(value: 3)
        collectObserver.sendCompleted()
        print(buffer)
        
        //
        buffer = sectionStr(sectionName: "Combining - combineLatest")
        
        let (numbersToCombineSignal, numbersToCombineObserver) = Signal<Int, NoError>.pipe()
        let (lettersToCombineSignal, lettersToCombineObserver) = Signal<String, NoError>.pipe()
        
        numbersToCombineSignal
            .combineLatest(with: lettersToCombineSignal)
            .observe { combinedEvent -> () in
                switch combinedEvent {
                case let .value(number, letter):
                    buffer = buffer + "number: " + String(number) + " letter: " + String(letter) + "\n"
                case .failed:
                    buffer = buffer + "failed\n"
                case .completed:
                    buffer = buffer + "completed\n"
                case .interrupted:
                    buffer = buffer + "interrupted\n"
                }
        }
        numbersToCombineObserver.send(value: 0)      // nothing printed, no letter yet
        numbersToCombineObserver.send(value: 1)      // nothing printed, no letter yet
        lettersToCombineObserver.send(value: "A")     // prints (1, A)
        numbersToCombineObserver.send(value: 2)      // prints (2, A)
        numbersToCombineObserver.sendCompleted() // nothing printed
        lettersToCombineObserver.send(value: "B")    // prints (2, B)
        lettersToCombineObserver.send(value: "C")    // prints (2, C)
        lettersToCombineObserver.sendCompleted()  // prints completed
        print(buffer)
    }
    
    func signalsEx() {
    
        // http://mfclarke.github.io/2016/04/23/introduction-to-reactive-cocoa-4/
        
        enum IntError: Error {
            case SomeErrorHappened
        }
        
        let (signal, observer) = Signal<Int, IntError>.pipe()
        let disposable = signal.observeResult { (result) in
            if let x = result.value {
                print(x)
            }
        }
        
        signal.observeResult { (result) in
            if let val = result.value {
                let x = 1.0 / Float(val)
                print(x)
            }
        }
        
        signal.observe { (event) in
            //print(event.value)
        }
        
        signal.observeFailed { (error) in
            let e = error
            print(e)
        }
        
        observer.send(value: 10)
        //observer.send(error: .SomeErrorHappened)
        //observer.sendCompleted()
        disposable?.dispose()
        observer.send(value: 5)
    }
    
}

