//
//  ContentView.swift
//  RealmFetchSample
//
//  Created by yumenosuke koukata on 2020/03/18.
//  Copyright © 2020 yumenosuke koukata. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
	
	@ObservedObject(initialValue: ContentViewModel()) var viewModel: ContentViewModel
	
    var body: some View {
		VStack {
			Text("Realm Test")
			TextField("URL", text: $viewModel.url)
			Button(action: viewModel.fetchTapped.send) { Text(viewModel.fetchButtonLabel) }
				.disabled(!viewModel.isFetchEnabled)
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
