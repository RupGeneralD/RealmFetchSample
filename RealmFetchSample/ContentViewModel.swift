//
//  ContentViewModel.swift
//  RealmFetchSample
//
//  Created by yumenosuke koukata on 2020/03/18.
//  Copyright © 2020 yumenosuke koukata. All rights reserved.
//

import Foundation
import Combine

public class ContentViewModel: ObservableObject, Identifiable {
	
	// Input
	let fetchTapped = PassthroughSubject<Void, Never>()
	@Published var url = "https://"
	
	// Output
	@Published var fetchButtonLabel = "Fetch"
	@Published var isFetchEnabled = false
	
    private var cancellables: [AnyCancellable] = []

	private(set) lazy var onDisappear: () -> Void = { [weak self] in
        guard let self = self else { return }
        self.cancellables.forEach { $0.cancel() }
        self.cancellables = []
    }
	
	init() {
		$url.map { $0.hasPrefix("http://") || $0.hasPrefix("https://") }
		.sink { [weak self] in self?.isFetchEnabled = $0 }
		.store(in: &self.cancellables)
		
		fetchTapped
			.sink { [weak self] _ in
				self?.fetchButtonLabel = "Fetching..."
		}.store(in: &cancellables)
	}
}
