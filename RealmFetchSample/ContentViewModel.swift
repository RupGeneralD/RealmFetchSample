//
//  ContentViewModel.swift
//  RealmFetchSample
//
//  Created by yumenosuke koukata on 2020/03/18.
//  Copyright © 2020 yumenosuke koukata. All rights reserved.
//

import Foundation
import Combine
import Alamofire
import RealmSwift

public class ContentViewModel: ObservableObject, Identifiable {
	
	// Input
	let fetchTapped = PassthroughSubject<Void, Never>()
	let makeRealmTapped = PassthroughSubject<Void, Never>()
	@Published var url = "http://localhost:8888/default.realm"
	@Published var thing = "xxxx on the floor"
	@Published var recoverable = false
	
	// Output
	@Published var fetchButtonLabel = "Fetch"
	@Published var isFetchEnabled = false
	@Published var makeRealmButtonLabel = "Make Realm"
	@Published private(set) var realmFileName: String?
	
    private var cancellables: [AnyCancellable] = []

	private(set) lazy var onDisappear: () -> Void = { [weak self] in
        self?.cancellables.clear()
    }
	
	init() {
		$url.map { $0.hasPrefix("http://") || $0.hasPrefix("https://") }
		.sink { [weak self] in self?.isFetchEnabled = $0 }
		.store(in: &self.cancellables)
		
		$url.compactMap { URL(string: $0)?.lastPathComponent }
			.sink { [weak self] in self?.realmFileName = $0 }
			.store(in: &self.cancellables)
		
		$realmFileName
			.compactMap { $0 }
			.map { "Fetch \($0)" }
			.sink{ [weak self] in self?.fetchButtonLabel = $0 }
			.store(in: &cancellables)
		
		fetchTapped
			.sink { [weak self] _ in
				guard let s = self else { return }
				AF.request(s.url, method: .post).responseData { response in
					guard let s = self,
						let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(s.realmFileName ?? "default.realm"),
						let data = response.data else { return }

					try? FileManager.default.removeItem(at: path)
					try? data.write(to: path)
				}
		}.store(in: &cancellables)
		
		makeRealmTapped
			.sink { [weak self] in
				guard let s = self, let realm = try? Realm() else { return }
//				var stupids = realm.objects(Stupid.self)
				let item = Stupid()
				item.thing = s.thing
				item.recoverable = s.recoverable
				try? realm.write {
					realm.add(item)
				}
		}.store(in: &cancellables)
	}
}
