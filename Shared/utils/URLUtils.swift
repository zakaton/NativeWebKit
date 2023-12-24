import Foundation

extension URL {
    var deepLinkScheme: String { "nativewebkit" }
    var deepLinkPrefix: String { "\(deepLinkScheme)://" }
    var isDeeplink: Bool {
        scheme == deepLinkScheme
    }

    var deepLinkUrl: String? {
        if isDeeplink {
            var urlString = absoluteString.removePrefix(deepLinkPrefix)
            if urlString.hasPrefix("https//") {
                urlString = urlString.replacePrefix("https//", with: "https://")
            }
            if urlString.hasPrefix("http//") {
                urlString = urlString.replacePrefix("http//", with: "http://")
            }
            return urlString
        }
        return nil
    }
}
