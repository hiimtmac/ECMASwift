Pod::Spec.new do |spec|
    
    spec.name         = "ECMASwift"
    spec.version      = "0.4.0"
    spec.summary      = "ECMAScript strong typing helpers for Swift"
    spec.description  = <<-DESC
    Swift/JS helpers to get/set variables, run methods, send
    notifications on a WKWebview. Utilized PromiseKit to convert
    WKWebView completion handlers into chainable promises.
    DESC
    
    spec.homepage           = "https://github.com/hiimtmac/ECMASwift"
    spec.license            = { :type => "MIT", :file => "LICENSE" }
    spec.author             = { "hiimtmac" => "taylor@hiimtmac.com" }
    spec.platform           = :ios, "13.0"
    spec.source             = { :git => "https://github.com/hiimtmac/ECMASwift.git", :tag => "#{spec.version}" }
    spec.source_files       = "Sources/ECMASwift/**/*.swift"
    spec.requires_arc       = true
    spec.swift_version      = "5.2"
    spec.framework  = "WebKit"
    
end
