//
//  CancellableArrayExtension.swift
//  RealmFetchSample
//
//  Created by yumenosuke koukata on 2020/03/18.
//  Copyright © 2020 yumenosuke koukata. All rights reserved.
//

import Foundation
import Combine

extension Array where Element: Cancellable {
	public func cancel() {
		forEach { $0.cancel() }
	}
	
	mutating public func clear() {
		cancel()
		self = []
	}
}
