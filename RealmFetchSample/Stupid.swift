//
//  Stupid.swift
//  RealmFetchSample
//
//  Created by yumenosuke koukata on 2020/03/18.
//  Copyright © 2020 yumenosuke koukata. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
public class Stupid: Object, Identifiable {
	public dynamic var thing = ""
	public dynamic var recoverable = true
}
