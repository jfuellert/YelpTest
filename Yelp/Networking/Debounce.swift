//
//  Debounce.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-25.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import Foundation

class Debounce {
    
    // MARK: - Properties
    var handler: (() -> Void)?
    
    private let timeInterval: TimeInterval
    private var timer: Timer?
    
    // MARK: - Init
    init(_ timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    // MARK: - Updates
    func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] timer in
            self?.handleTimer(timer)
        })
    }
    
    private func handleTimer(_ timer: Timer) {
        guard timer.isValid else {
            return
        }
        handler?()
        handler = nil
    }
}
