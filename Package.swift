// swift-tools-version:5.0
import PackageDescription

let package = Package(
	name: "SQLClient",
	products: [
		.library(name: "SQLClient", targets: ["SQLClient"]),
	],
	targets: [
		.target(
			name: "SQLClient",
			path: "SQLClient/SQLClient/SQLClient",
			publicHeadersPath: "spm_include",
			linkerSettings: [.linkedLibrary("iconv")]
		),
	]
)