//
//  instagram_cloneApp.swift
//  instagram-clone
//
//  Created by Anderson  on 2024/11/22.
//

import SwiftUI
import Env

@main
struct instagram_cloneApp: App {
	init() {
		let env = Envionment.current
		debugPrint(env)
	}
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
