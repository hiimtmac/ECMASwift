# ECMASwift

> Goal of this library is to package error prone string functionality into stronger typed composable pieces

### Installation

Requirements:
- iOS 12.0+
- Swift 5.0+

In your podfile
```ruby
platform :ios, '12.0'

source 'https://github.com/hiimtmac/specs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'MyProj' do
    use_frameworks!

    pod 'ECMASwift'

end
```

## WKWebView

Extensions using [PromiseKit](https://github.com/mxcl/PromiseKit)

##### Before
```swift
webView.evaluateJavaScript(javaScriptString, completionHandler: { (any, error) in
    if let error = error {
        print(error)
    } else if let any = any as? MyType {
        print(any)
    } else {
        // what do??
    }
})
// Can't reuse this!
```

##### After
```swift
webView.evaluateJavaScript("string;", as: String.self) // -> returns Promise<String>
```

There are 2 versions, one returning a type, and another for void returns.
```swift
func evaluateJavaScript(_ javaScriptString: String) -> Promise<Void>
func evaluateJavaScript<T: Decodable>(_ javaScriptString: String, as: T.Type) -> Promise<T>
```

These can be chained together to do more complex things given:
```html
<script>
    var string = "hello";
</script>
```

```swift
firstly {
    webView.evaluateJavaScript("string;", as: String.self)
}.get {
    print($0) // hello
}.then {
    self.webView.evaluateJavaScript("string = \"hi there!\";")
}.then {
    self.webView.evaluateJavaScript("string;", as: String.self)
}.get {
    print($0) // hi there!
}.catch {
    print($0) // error if there was
}
```

This would previously have to been accomplished with a ton of nested completion handlers creating a pyramid of doom!

### Helper Methods

Helper methods for common tasks
- get variable `getVariable<T: Decodable>(...)`
- set variable `setVariable(...)`
- call method with no return `runVoid(...)`
- call method with return value `runReturning<T: Decodable>`

```swift
func getVariable<T: Decodable>(named: String, as type: T.Type) -> Promise<T>
func setVariable(named: String, value: JavaScriptParameterEncodable) -> Promise<Void>
func runVoid(named: String, args: [JavaScriptParameterEncodable] = []) -> Promise<Void>
func runReturning<T: Decodable>(named: String, args: [JavaScriptParameterEncodable] = [], as type: T.Type) -> Promise<T>
```

These methods would simplify the above example to
```swift
firstly {
    webView.getVariable(named: "string", as: String.self)
}.get {
    print($0) // hello
}.then { _ in
    self.webView.setVariable(named: "string", value: "hi there!")
}.then {
    self.webView.getVariable(named: "string", as: String.self)
}.get {
    print($0) // hi there!
}.catch {
    print($0) // error if there was
}
```
> These are helpful as you don't have to remember about pesky `;` placement

### JavaScriptParameterEncodable

Any value that conforms to `JavaScriptParameterEncodable` can be used as arguments to set a variable or call a function with arguments. Types that also conform to `Encodable` get this encoding behavior for free. You don't have to worry about quote escaping and such. Combining the stronger typed helper methods with the `JavaScriptParameterEncodable` protocol will transform something like

```html
<script>
    function returnContents(contents) {
        return contents;
    }
</script>
```
```swift
struct JSON: Codable {
    let name: String
    let age: Int
}
```
> Obviously this is a contrived example as we are expecting the same type back as we put in

##### Before
```swift
// simple types
let javaScriptString = "returnContent(\"tmac\");" // cant just shove JSON(name: "tmac", age: 28) in there
webView.evaluateJavaScript(javaScriptString, completionHandler: { (any, error) in
    if let error = error {
        print(error) // error if there was
    } else if let any = any as? String {
        print(any) // "tmac"
    } else {
        // what do??
    }
})
// Can't reuse this!

let javaScriptString = "returnContent({\"name\":\"tmac\",\"age\":28});"
webView.evaluateJavaScript(javaScriptString, completionHandler: { (any, error) in
    if let error = error {
        print(error) // error if there was
    } else if let any = any {
        let encoded = try JSONSerialization.data(withJSONObject: any, options: []) // Any -> Data
        let decoded = try JSONDecoder().decode(JSON.self, from: encoded) // Data -> Object
        print(decoded) // { name: "tmac", age: 28 }
    } else {
        // what do??
    }
})
// Can't reuse this!
```

##### After
```swift
// simple types
firstly {
    webView.runReturning(named: "returnContents", args: ["tmac"], as: String.self)
}.get {
    print($0) // "tmac"
}.catch {
    print($0) // error if there was
}

// more complex types
extension JSON: JavaScriptParameterEncodable {}

firstly {
    webView.runReturning(named: "returnContents", args: [JSON(name: "tmac", age: 28)], as: JSON.self)
}.get {
    print($0) // { name: "tmac", age: 28 }
}.catch {
    print($0) // error if there was
}
```

## ESWebView

`ESWebView` is a subclass of `WKWebView` with some extended functionality. In javascript, you can reach out and message into swift-land using
```javascript
window.webkit.messageHandlers.MyMessageHandler.postMessage({message: "hello"});
```

This requires you to be subscribed to messaging on the webview with
```swift
public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    print(message.name) // MyMessageHandler
    print(message.body) // Any 🤮
}
```

`ESWebView` listens for 3 message handlers (and does all the work subscribing for messaging), looking for data in 3 formats
```swift
private let kMessage = "ECMASwiftMessage"
public struct Message: Codable {
    public let message: String
}
// used for sending a message to swift-land

private let kPrompt = "ECMASwiftPrompt"
public struct Prompt: Codable {
    public let name: String
    public let type: HandlerType
}
// used to prompt swift-land to reach in and grab a variable or run a function

private let kRequest = "ECMASwiftRequest"
public struct Request: Codable {
    public let object: String
    public let predicate: String?
    public let toHandler: String
    public let type: HandlerType
}
// used for requesting a type or types from swift-land

// handler type
public enum HandlerType: String, Codable {
    case variable
    case function
}
```

These can be used in javascript to send messages which will be posted to iOS's `NotificationCenter`.
```javascript
window.webkit.messageHandlers.ECMASwiftMessage.postMessage({message: "hello"});
window.webkit.messageHandlers.ECMASwiftPrompt.postMessage({name: "name", type: "variable"});
window.webkit.messageHandlers.ECMASwiftRequest.postMessage({object: "JSON", toHandler: "setPeople", type: "function"});
```

Subscribe in your view controller for any of these 3 notifications (and for a 4th error notification)

#### Example

```swift
import UIKit
import ECMASwift
import PromiseKit

class ViewController: UIViewController {

    var webView: ESWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup webView

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: ESWebView.error, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: ESWebView.request, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: ESWebView.prompt, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: ESWebView.message, object: nil)
    }

    // something in webView triggers window.webkit.messageHandlers.ECMASwiftXXXXXXX.postMessage(...)
    @objc func handleNotification(_ notification: Notification) {
        let userInfo = notification.userInfo!
        if let message = userInfo["message"] as? ESWebView.Message {
            // do something with message
        } else if let prompt = userInfo["prompt"] as? ESWebView.Prompt {
            // webView.getVariable(named: "name", as: String.self)
        } else if let request = userInfo["request"] as? ESWebView.Request {
            // let jsons: [JSON] = ...
            // webView.runVoid(named: "setPeople", args: [jsons])
        } else {
            print(userInfo["attempting"]) // message / prompt / request
            print(userInfo["error"]) // error message
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
```

## WKUIDelegate

`ESWebView` sets its `uiDelegate` to `self` in the initializer. This allows us to capture events from javascript such as alerts, confirmations, and text input panels.

```swift
public var handleAlertPanel: ((_ message: String, _ completionHandler: @escaping () -> Void) -> Void)?
public var handleConfirmPanel: ((_ message: String, _ completionHandler: @escaping (Bool) -> Void) -> Void)?
public var handleTextInputPanel: ((_ prompt: String, _ defaultText: String?, _ completionHandler: @escaping (String?) -> Void) -> Void)?
```

Set any of the above properties on your webView to handle these events. Not setting them (or setting them to nil) will result in the default behavior the system would take if the `uiDelegate` property was not set.

```swift
webView.handleAlertPanel = { [weak self] message, completion in
    let ac = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        completion()
    })
    self?.present(ac, animated: true)
}

webView.handleConfirmPanel = { [weak self] message, completion in
    let ac = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
        completion(true)
    })
    ac.addAction(UIAlertAction(title: "NO", style: .default) { _ in
        completion(false)
    })
    self?.present(ac, animated: true)
}

webView.handleTextInputPanel = { [weak self] message, defaultText, completion in
    let ac = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
    ac.addTextField(configurationHandler: { (tf) in
        tf.placeholder = "hello"
        tf.text = defaultText
    })
    ac.addAction(UIAlertAction(title: "Yes", style: .default) { [unowned ac] _ in
        completion(ac.textFields?.first?.text)
    })
    ac.addAction(UIAlertAction(title: "NO", style: .default) { _ in
        completion(nil)
    })
    self?.present(ac, animated: true)
}
```

## String Interpolation

`JavaScriptParameterEncodable` objects can be string interpolated using

```swift
struct Object: Codable, JavaScriptParameterEncodable {
    let name: String
}

let javaScriptString = "var myVar = \(asJS: Object(name: "tmac")"
// "var myVar = {\"name\":\"tmac\"}"
```
