

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: "https://www.facebook.com/tooru.sonehara") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
