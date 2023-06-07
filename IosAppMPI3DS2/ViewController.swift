//
//  ViewController.swift
//  IosAppMPI3DS2
//
//  Created by MacBook  on 7/21/22.
//

import UIKit
import WebKit

class ViewController: UIViewController, XMLParserDelegate {
    let webView: WKWebView = WKWebView()

    var sessionID :String = ""
    var redirectHTML: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "telr", options: .new, context: nil)
//        view = webView
//        let url = URL(string: "https://www.hackingwithswift.com/")!
//        webView.load(URLRequest(url: url))
//        webView.allowsBackForwardNavigationGestures = true
        
        //loadWebView(redirectHtml: "Test")
    }
    
    
    @IBAction func startAPiCallMethod(_ sender: Any) {
        
        self.showAlerrt(title: "MPI #3DS2 API", msg: "All calling is started, please wait for few movements as we connecting to server for OTP challenge!")
        startMPICAll()
        
    }
    
    // Observe value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            print("observeValue \(key)") // url value
        }
    }
    
    func loadWebView(redirectHtml:String){
        
        let htmlStg :String = """
        <html>
        <head></head>
        <body>
        <script type="text/javascript">

        function show3DSChallenge(){
                var redirect_html="\(redirectHtml)";
                var txt = document.createElement("textarea");
                txt.innerHTML = redirect_html;
                redirect_html_new = decodeURIComponent(txt.value);
                document.body.innerHTML = redirect_html_new;
                eval(document.getElementById('authenticate-payer-script').text)
                
                }
        show3DSChallenge();
        </script>
        </body>
        </html>
        """
        let htmlStg1 :String = """
        <html>
        <head></head>
        <body>
        <script type="text/javascript">

        function show3DSChallenge(){
                var redirect_html="%3cdiv%20id%3d%22threedsChallengeRedirect%22%20xmlns%3d%22http%3a%2f%2fwww.w3.org%2f1999%2fhtml%22style%3d%22%20height%3a%20100vh%22%3e%20%3cform%20id%20%3d%22threedsChallengeRedirectForm%22%20method%3d%22POST%22%20action%3d%22https%3a%2f%2fap.gateway.mastercard.com%2facs%2fvisa%2fv2%2fprompt%22%20target%3d%22challengeFrame%22%3e%20%3cinput%20type%3d%22hidden%22%20name%3d%22creq%22%20value%3d%22eyJ0aHJlZURTU2VydmVyVHJhbnNJRCI6ImQxZGIxMzE3LTI3ODItNGU5Yi05NGIxLTk5NGYyMGFhOTU5MCJ9%22%20%2f%3e%20%3c%2fform%3e%20%3ciframe%20id%3d%22challengeFrame%22%20name%3d%22challengeFrame%22%20width%3d%22100%25%22%20height%3d%22100%25%22%20%3e%3c%2fiframe%3e%20%3cscript%20id%3d%22authenticate-payer-script%22%3e%20var%20e%3ddocument.getElementById(%22threedsChallengeRedirectForm%22);%20if%20(e)%20%7b%20e.submit();%20if%20(e.parentNode%20!%3d%3d%20null)%20%7b%20e.parentNode.removeChild(e);%20%7d%20%7d%20%3c%2fscript%3e%20%3c%2fdiv%3e";
                var txt = document.createElement("textarea");
                txt.innerHTML = redirect_html;
                redirect_html_new = decodeURIComponent(txt.value);
                document.body.innerHTML = redirect_html_new;
                eval(document.getElementById('authenticate-payer-script').text)
                
                }
        show3DSChallenge();

        </script>
        </body>
        </html>
        """
        print(htmlStg)
        
        webView.isHidden = false
        webView.loadHTMLString(htmlStg, baseURL: nil)
        webView.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.addSubview(webView)
        //self.navigationController?.pushViewController(webView, animated: true)
        
    }

    func startMPICAll(){
        let session = URLSession(configuration: .default)
        let url = URL(string: "https://uat-secure.telrdev.com/gateway/remote_mpi.xml")! //<-
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") //<-
        request.httpBody = """
        <?xml version="1.0" encoding="UTF-8"?>
        <remote>
            <store>15164</store>
            <key>w7HrQ-N5xKK^5nrV</key>
            <tran>
                <type>sale</type>
                <class>ecom</class>
                <cartid>atZGs9C762</cartid>
                <description>Test Remote API</description>
                <currency>AED</currency>
                <amount>1</amount>
                <test>1</test>
            </tran>
            <card>
                <number>4000000000000002</number>
                <expiry>
                    <month>01</month>
                    <year>39</year>
                </expiry>
                <cvv>123</cvv>
            </card>
            <browser>
                <agent>Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36</agent>
                <accept>*/*</accept>
            </browser>
                <mpi>
                <returnurl>https://www.telr.com</returnurl>
            </mpi>
        </remote>
        """.data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            // do something with the result
            print(data)
            
            if let data = data {
                print(String(data: data, encoding: .utf8))
                
                let str = String(data: data, encoding: .utf8)!
                print(str)

                
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()

                DispatchQueue.main.async {
                    let xmlresponse = XML.parse(data)
                    if let meg = xmlresponse["remote", "mpi", "session"].text{
                    self.sessionID = xmlresponse["remote", "mpi", "session"].text!
                        print(self.sessionID)
                    self.redirectHTML =  xmlresponse["remote", "mpi", "redirecthtml"].text!
                        
                        print(self.redirectHTML)
                        self.loadWebView(redirectHtml: self.redirectHTML)
                    }
                }
                
                //print(message)
            } else {
                print("no data")
            }
        }
        task.resume()

    }
    
    func verifyAuthAPICall(){
        let session = URLSession(configuration: .default)
        let url = URL(string: "https://uat-secure.telrdev.com/gateway/remote.xml")! //<-
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") //<-
        let reqBody = """
        <?xml version="1.0" encoding="UTF-8"?>
        <remote>
            <store>15164</store>
            <key>w7HrQ-N5xKK^5nrV</key>
            <tran>
                <type>sale</type>
                <class>ecom</class>
                <cartid>atZGs9C762</cartid>
                <description>Test Remote API</description>
                <test>1</test>
                <currency>AED</currency>
                <amount>1</amount>
            </tran>
            <card>
                <number>4000000000000002</number>
                <expiry>
                    <month>01</month>
                    <year>39</year>
                </expiry>
                <cvv>123</cvv>
            </card>
            <billing>
                <name>
                    <title>MR</title>
                    <first>Krishna</first>
                    <last>Zore</last>
                </name>
                <address>
                    <line1>SIT TOWER</line1>
                    <city>Dubai</city>
                    <region>Dubai</region>
                    <country>AE</country>
                </address>
                <email>krishna.zore@telr.com</email>
                <ip>106.193.225.18</ip>
            </billing>
            <mpi>
                <session>\(self.sessionID)</session>
            </mpi>
        </remote>
        """
        print(reqBody)
        request.httpBody = reqBody.data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            // do something with the result
            print(data)
            
            if let data = data {
                print(String(data: data, encoding: .utf8))
                
                let str = String(data: data, encoding: .utf8)!
                print(str)

                
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()

                DispatchQueue.main.async {
                    let xmlresponse = XML.parse(data)
                    if let meg = xmlresponse["remote", "auth", "message"].text{
                    let messg = xmlresponse["remote", "auth", "message"].text!
                        print(self.sessionID)
                    let trsrRref =  xmlresponse["remote", "auth", "tranref"].text!
                    let authStatus =  xmlresponse["remote", "auth", "status"].text!
                        self.showAlerrt(title: messg, msg: "Auth Status: **\(authStatus)** with Transaction refference:\(trsrRref)")
                    
                    }
                }
                
                //print(message)
            } else {
                print("no data")
            }
        }
        task.resume()

    }
    
    func showAlerrt(title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }

}



extension ViewController : WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate{
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
      {
            print(error.localizedDescription)
       }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let host = navigationAction.request.url?.host {
                //print(#function, host)
                if host.contains("telr.com") {
                    
                    decisionHandler(.cancel)
                    DispatchQueue.main.async {
                        webView.isHidden = true
                        self.verifyAuthAPICall()
                    }
                    return
                }
            }
            
            decisionHandler(.allow)
        }
       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
       {
            //        UIApplication.shared.isNetworkActivityIndicatorVisible = true
            print("Strat to load")
           let when = DispatchTime.now() + 10  // No waiting time
           DispatchQueue.main.asyncAfter(deadline: when) {
               
           }
       }

//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("in challenge")
//    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        if (webView.url?.path.contains("https://www.telr.com"))!{
            print("redirect happening!!")
        }
    }
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("redirect happening!! new ")
        
    }
}
