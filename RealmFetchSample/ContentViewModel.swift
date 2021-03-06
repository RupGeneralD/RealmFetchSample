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
	@Published private(set) var fetchButtonLabel = "Fetch"
	@Published private(set) var isFetchEnabled = false
	@Published private(set) var makeRealmButtonLabel = "Make Realm"
	@Published private(set) var realmFileName: String?
	@Published private(set) var items: [Stupid] = []
	
	private var cancellables: [AnyCancellable] = []
	
	private var realmFileURL: URL? {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
			.first?.appendingPathComponent(realmFileName ?? "default.realm")
	}
	
	private var realmRelatedFileURLs: [URL] {
		[
			realmFileURL,
			realmFileURL?.appendingPathExtension("lock"),
			realmFileURL?.appendingPathExtension("management")
			].compactMap { $0 }
	}
	
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
			.tryCompactMap { _ in URL(string: self.url) }
			.flatMap { URLSession.shared.dataTaskPublisher(for: $0).mapError { $0 as Error } }
			.map { $0.data }
			.eraseToAnyPublisher()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { e in print("Fetching error...") },
				  receiveValue: { [weak self] data in
					guard let _ = autoreleasepool(invoking: { (try? Realm()).flatMap { try? $0.write($0.deleteAll)}}), // to clear also realm cache
						let _ = self?.realmRelatedFileURLs.forEach({ try? FileManager.default.removeItem(at: $0) }), // clear files
						let path = self?.realmFileURL,
						let _ = try? data.write(to: path, options: .atomicWrite), // place downloaded realm file
						let stupids = autoreleasepool(invoking: { (try? Realm()).map{ Array($0.objects(Stupid.self)) }}) // open realm stream again and make array to evaluate them
						else { return } // is everything ok?
					self?.items = stupids
					print("Fetched realm file has \(stupids.count) items")
			})
			.store(in: &cancellables)
		
		makeRealmTapped
			.sink { [weak self] in
				guard let s = self, let realm = try? Realm() else { return }
				let item = Stupid()
				item.thing = s.thing
				item.recoverable = s.recoverable
				try? realm.write {
					realm.add(item)
					self?.items.append(item)
				}
		}.store(in: &cancellables)
	}
}
