import UIKit
import WebKit

public class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    var webView: WKWebView!

    // Property to hold the HTML string to be loaded
    var htmlStringToLoad: String?

    // Property to keep track of the height constraint
    var heightConstraint: NSLayoutConstraint!

    public override func viewDidLoad() {
        super.viewDidLoad()

        do {
            // Initialize WKWebView with zero frame initially, it will be updated with layout
            let webViewConfiguration = WKWebViewConfiguration()

            // Add the script message handler to listen for JavaScript messages
            webViewConfiguration.userContentController.add(self, name: "onCloseWebView")
            webViewConfiguration.userContentController.add(self, name: "onImageClicked")
            webViewConfiguration.userContentController.add(self, name: "onButtonClick")
            webViewConfiguration.userContentController.add(self, name: "onFormDataReceived")

            webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.navigationDelegate = self
            self.view.addSubview(webView)

            // Add Auto Layout constraints to center the webView and allow resizing
            NSLayoutConstraint.activate([
                webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                webView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
            ])

            // Set up height constraint (initially set to 0)
            heightConstraint = webView.heightAnchor.constraint(equalToConstant: 0)
            heightConstraint.isActive = true

            // If htmlStringToLoad is already set before viewDidLoad, load the HTML string immediately
            if let htmlString = htmlStringToLoad {
                loadHTML(htmlString)
            }
        } catch {
            print("Error in viewDidLoad: \(error)")
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        do {
            EventManager.shared.sendPopupEvent(eventName: EventNames.popUpAction.rawValue, popupActionProperty: PopupActionEventProperty.popupView.rawValue, popupAction: PopupActionName.view.rawValue, actionValue: "")

            // This ensures the view is fully loaded before calling loadHTML if it wasn't done in viewDidLoad
            if let htmlString = htmlStringToLoad, webView.url == nil {
                loadHTML(htmlString)
            }
        } catch {
            print("Error in viewDidAppear: \(error)")
        }
    }

    public func loadHTML(_ htmlString: String) {
        do {
            // Ensure that the webView is initialized before trying to load content
            htmlStringToLoad = htmlString
            guard let webView = self.webView else {
                print("Error: WKWebView is not initialized.")
                return
            }

            // Load the HTML string into WebView
            webView.loadHTMLString(htmlString, baseURL: nil)
        } catch {
            print("Error in loadHTML: \(error)")
        }
    }

    // MARK: - WKNavigationDelegate

    // This method will be called once the page has finished loading
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        do {
            // Inject JavaScript to get the content height
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (result, error) in
                if let contentHeight = result as? CGFloat {
                    // Update the height constraint based on the content height
                    self.heightConstraint.constant = contentHeight
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded() // Ensure the layout is updated with animation
                    }
                } else {
                    print("Error getting content height: \(error?.localizedDescription ?? "Unknown error")")
                }
            }

            let campaignId = UserDefaults.standard.string(forKey: "campaignIdMergn") ?? "0000"

            let closeJavascript = """
            document.querySelector('.u-close-button').addEventListener('click', function() {
                window.webkit.messageHandlers.onCloseWebView.postMessage({
                    campaignId: \(campaignId),
                    buttonId: 'u-close-button'
                });
            });
            """

            // Inject JavaScript into the WebView
            webView.evaluateJavaScript(closeJavascript, completionHandler: nil)

            let javascript = """
            try {
                document.querySelectorAll('.u-popup-container img').forEach(e => {
                    e.addEventListener('click', async () => {
                        try {
                            const imageSrc = e.src;
                            const imageId = e.id;
                            window.webkit.messageHandlers.onImageClicked.postMessage({
                                campaignId: \(campaignId),
                                imageClassName: e.className,
                                imageId: e.id,
                                imageSrc: e.src
                            });
                        } catch (error) {
                            window.webkit.messageHandlers.closeDialog.postMessage(error.toString());
                        }
                    });
                });
            } catch (error) {
                window.webkit.messageHandlers.closeDialog.postMessage(error.toString());
            }
            """

            // Inject the JavaScript into the WKWebView
            webView.evaluateJavaScript(javascript, completionHandler: nil)

            let buttonScript = """
            (function() {
                var buttonIds = [];
                document.querySelectorAll('[id^=u_content_button_]').forEach(function(element) {
                    try {
                        var buttonLink = element.querySelector('a');
                        var href = buttonLink ? buttonLink.getAttribute('href') : 'not_defined';
                        var target = buttonLink ? buttonLink.getAttribute('target') : 'not_defined';
                        element.addEventListener('click', function() {
                            if (href === 'not_defined' || href.trim() === '') {
                                window.webkit.messageHandlers.onButtonClick.postMessage({
                                    campaignId: \(campaignId),
                                    buttonId: element.id,
                                });
                            } else {
                                window.webkit.messageHandlers.onButtonClick.postMessage({
                                    campaignId: \(campaignId),
                                    buttonId: element.id,
                                    href: href,
                                    target: target
                                });
                            }
                        });
                        buttonIds.push(element.id);
                    } catch (error) {
                        window.webkit.messageHandlers.closeDialog.postMessage(error.toString());
                    }
                });
                return buttonIds.join(',');
            })();
            """
            // Inject JavaScript into the WKWebView
            webView.evaluateJavaScript(buttonScript, completionHandler: nil)

            let javascriptForm = """
            document.querySelectorAll('[id^="u_content_form_"]').forEach(formDiv => {
                const form = formDiv.querySelector('form');
                if (form) {
                    form.addEventListener('submit', async (event) => {
                        event.preventDefault();
                        const formData = new FormData(form);
                        const formValuesMap = {};
                        for (const [name, value] of formData.entries()) {
                            formValuesMap[name] = value;
                        }
                        window.webkit.messageHandlers.onFormDataReceived.postMessage({
                            campaignId: \(campaignId),
                            formId: formDiv.id,
                            formValues: formValuesMap
                        });
                    });
                }
            });
            """

            webView.evaluateJavaScript(javascriptForm, completionHandler: nil)

            let javascriptLink = """
            (function() {
                var linkIds = [];
                document.querySelectorAll('a').forEach(function(element, index) {
                    try {
                        var href = element.getAttribute('href') || 'not_defined';
                        var target = element.getAttribute('target') || 'not_defined';
                        var linkId = element.id || 'link_' + index;
                        element.addEventListener('click', function(event) {
                            if (href === 'not_defined' || href.trim() === '') {
                                window.webkit.messageHandlers.onButtonClick.postMessage({
                                    campaignId: '\(campaignId)',
                                    buttonId: linkId,
                                });
                            } else {
                                window.webkit.messageHandlers.onButtonClick.postMessage({
                                    campaignId: '\(campaignId)',
                                    buttonId: linkId,
                                    href: href,
                                    target: target
                                });
                            }
                        });
                        linkIds.push(linkId);
                    } catch (error) {
                        window.webkit.messageHandlers.onButtonClick.postMessage({
                            error: error.toString()
                        });
                    }
                });
                return linkIds.join(',');
            })();
            """

            webView.evaluateJavaScript(javascriptLink, completionHandler: nil)

        } catch {
            print("Error in webView didFinish navigation: \(error)")
        }
    }

    // This method intercepts link clicks and opens them externally if necessary
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        do {
            if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
                if url.scheme == "http" || url.scheme == "https" {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        } catch {
            print("Error in decidePolicyFor navigationAction: \(error)")
            decisionHandler(.allow)
        }
    }

    // Optional: Handle errors during page loading
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error loading content: \(error.localizedDescription)")
    }

    // MARK: - WKScriptMessageHandler

    public func userContentController(_ userContentController: WKUserContentController,
                                       didReceive message: WKScriptMessage) {
        do {
            if message.name == "onCloseWebView" {
                if let body = message.body as? [String: Any],
                   let campaignId = body["campaignId"] as? Int,
                   let buttonId = body["buttonId"] as? String {
                    print("Campaign ID: \(campaignId), Button ID: \(buttonId)")
                    let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                    if let jsonString = String(data: jsonData!, encoding: .utf8) {
                        print("Received JSON String: \(jsonString)")
                        EventManager.shared.sendPopupEvent(eventName: EventNames.popUpAction.rawValue, popupActionProperty: PopupActionEventProperty.popupCloseClick.rawValue, popupAction: PopupActionName.close.rawValue, actionValue: jsonString)
                    }
                }
                self.closeWebView()
            }

            if message.name == "onImageClicked" {
                if let body = message.body as? [String: Any] {
                    if let campaignId = body["campaignId"] as? Int,
                       let imageClassName = body["imageClassName"] as? String,
                       let imageId = body["imageId"] as? String,
                       let imageSrc = body["imageSrc"] as? String {
                        print("Campaign ID: \(campaignId), Image Class Name: \(imageClassName), Image ID: \(imageId), Image Source: \(imageSrc)")
                        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData!, encoding: .utf8) {
                            print("Received JSON String: \(jsonString)")
                            EventManager.shared.sendPopupEvent(eventName: EventNames.popUpAction.rawValue, popupActionProperty: PopupActionEventProperty.popupImageClick.rawValue, popupAction: PopupActionName.click.rawValue, actionValue: jsonString)
                        }
                    }
                }
                self.closeWebView()
            }

            if message.name == "onButtonClick" {
                if let body = message.body as? [String: Any] {
                    if let campaignId = body["campaignId"] as? Int,
                       let buttonId = body["buttonId"] as? String {
                        print("Campaign ID: \(campaignId), Button ID: \(buttonId)")
                        if let href = body["href"] as? String,
                           let target = body["target"] as? String {
                            print("Href: \(href), Target: \(target)")
                        }
                        EventManager.shared.sendPopupEvent(eventName: EventNames.popUpAction.rawValue, popupActionProperty: PopupActionEventProperty.popupButtonClick.rawValue, popupAction: PopupActionName.click.rawValue, actionValue: buttonId)
                    }
                }
                self.closeWebView()
            }

            if message.name == "onFormDataReceived" {
                //Adding attribute and identity calling logic here
                guard message.name == "onFormDataReceived",
                          let body = message.body as? [String: Any],
                          let formValues = body["formValues"] as? [String: Any] else {
                        print("Invalid or missing form data")
                        return
                    }

                    var formValueList: [(key: String, value: String)] = []

                    for (key, rawValue) in formValues {
                        guard let attributes = EventManager.shared.getAttribute(byName: key), !attributes.name.isEmpty else {
                            continue
                        }

                        let value = "\(rawValue)"
                        let pair = (key, value)

                        if attributes.should_set_identity {
                            formValueList.insert(pair, at: 0)
                        } else {
                            formValueList.append(pair)
                        }
                    }


                    sendFormValuesWithDelay(formValueList: formValueList, message: message)



                self.closeWebView()
            }
        } catch {
            print("Error in userContentController: \(error)")
        }
    }

    func closeWebView() {
        do {
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Error in closeWebView: \(error)")
        }
    }

    //for ios 13 supported
    func sendFormValuesWithDelay(formValueList: [(String, String)], message: WKScriptMessage) {
        func sendAttribute(at index: Int) {
            guard index < formValueList.count else {
                // All attributes sent — send popup event
                if let body = message.body as? [String: Any],
                   let campaignId = body["campaignId"] as? Int,
                   let formId = body["formId"] as? String,
                   let formValues = body["formValues"] as? [String: Any] {

                    print("Campaign ID: \(campaignId), Form ID: \(formId)")
                    print("Form Values: \(formValues)")

                    if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("Received JSON String: \(jsonString)")
                        EventManager.shared.sendPopupEvent(
                            eventName: EventNames.popUpAction.rawValue,
                            popupActionProperty: PopupActionEventProperty.popupFormSubmit.rawValue,
                            popupAction: PopupActionName.form.rawValue,
                            actionValue: jsonString
                        )
                    }
                }
                return
            }

            let (key, value) = formValueList[index]
            print("Sending: \(key): \(value)")
            if !value.isEmpty {
                EventManager.shared.sendAttribute(attributeName: key, attributeValue: value)
            }

            let delay: TimeInterval = (index == 0) ? 3.0 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                sendAttribute(at: index + 1)
            }
        }

        sendAttribute(at: 0)
    }

//    // Dispatch sending with delays using async/await (iOS 15+)
//                        Task {
//                            for (index, (key, value)) in formValueList.enumerated() {
//                                print("Sending: \(key): \(value)")
//                                if !value.isEmpty {
//                                    EventManager.shared.sendAttribute(attributeName: key, attributeValue: value)
//                                }
//
//                                let delay: UInt64 = (index == 0) ? 3_000_000_000 : 1_000_000_000
//                                try? await Task.sleep(nanoseconds: delay)
//                            }
//                            if let body = message.body as? [String: Any] {
//                                if let campaignId = body["campaignId"] as? Int,
//                                   let formId = body["formId"] as? String,
//                                   let formValues = body["formValues"] as? [String: Any] {
//                                    print("Campaign ID: \(campaignId), Form ID: \(formId)")
//                                    print("Form Values: \(formValues)")
//                                    let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
//                                    if let jsonString = String(data: jsonData!, encoding: .utf8) {
//                                        print("Received JSON String: \(jsonString)")
//                                        EventManager.shared.sendPopupEvent(eventName: EventNames.popUpAction.rawValue, popupActionProperty: PopupActionEventProperty.popupFormSubmit.rawValue, popupAction: PopupActionName.form.rawValue, actionValue: jsonString)
//                                    }
//                                }
//                            }
//                        }
}
