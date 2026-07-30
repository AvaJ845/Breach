import Foundation

/// Privacy Policy & Terms — hosted on GitHub Pages and bundled for in-app reading.
enum AppLegal {
    static let privacyPolicyURL = URL(string: "https://avaj845.github.io/Breach/privacy.html")!
    static let termsOfUseURL = URL(string: "https://avaj845.github.io/Breach/terms.html")!
    static let marketingURL = URL(string: "https://avaj845.github.io/Breach/")!

    static let privacyResourceName = "PRIVACY"
    static let termsResourceName = "TERMS"

    static func bundledMarkdown(named name: String) -> String? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "md", subdirectory: "Legal")
                ?? Bundle.main.url(forResource: name, withExtension: "md") else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
