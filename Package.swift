// swift-tools-version:5.0

import PackageDescription

let package = Package(
	name: "StaticTable",
	platforms: [
		.iOS("14.0"),
		.macOS("12.0"),
	],
	products: [
		.library(
			name: "StaticTable",
			targets: ["StaticTable"]),
	],
	dependencies: [
		.package(url: "https://github.com/NoPassword-Swift/NPCombine.git", "0.0.1"..<"0.1.0"),
	],
	targets: [
		.target(
			name: "StaticTable",
			dependencies: [
				"NPCombine",
			]),
	]
)
