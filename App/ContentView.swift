//
//  ContentView.swift
//  instagram-clone
//
//  Created by Anderson  on 2024/11/22.
//

import AppUI
import SwiftUI

struct ContentView: View {
	@Environment(\.textTheme) var textTheme
//	@AppStorage("userTheme") private var userTheme: ColorTheme = .system
//	@State private var userTheme: ColorTheme = .system
	var body: some View {
		VStack {
			
		}

//			NavigationView {
//				VStack {
//					Assets.images.logo.view()
//					Button {} label: {
//						HStack {
//							Assets.icons.google.view(width: 24, height: 24)
//							Text("Sign in with Google")
//								.appTextStyle(textTheme.headlineMedium)
//								.foregroundStyle(userTheme.bodyColor())
//						}
//					}
//					Button {} label: {
//						HStack {
//							Assets.icons.github.view(width: 24, height: 24)
//							Text("Sign in with Google")
//								.appTextStyle(textTheme.headlineMedium)
//								.foregroundStyle(userTheme.bodyColor())
//						}
//					}
//				}
//				.frame(maxHeight: .infinity)
		////				.background(userTheme.appBarBackgroundColor())
//				.navigationTitle("Instagram-Clone")
//				.navigationBarTitleDisplayMode(.inline)
//				.toolbar {
//					ToolbarItem(placement: .topBarTrailing) {
//						Menu {
//							ForEach(ColorTheme.allCases, id: \.rawValue) { theme in
//								Button(theme.rawValue) {
//									userTheme = theme
//								}
//							}
//						} label: {
//							Image(systemName: "ellipsis.circle") // 或其他合适的系统图标
//						}
//					}
//				}
//			}
//			.preferredColorScheme(userTheme.colorScheme)
	}
}

struct ThemeTestView: View {
	@Environment(\.colorScheme) private var currentColorScheme

	var body: some View {
		VStack {
			
		}
		
	}
}

#Preview {
	ContentView()
}
