//
//  TermsAndConditionsPDFViewController.swift
//  EPIAL
//
//  Created by User on 14/06/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class TermsAndConditionsPDFViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    let activityIndicator = UIActivityIndicatorView()
    var urltaken : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        webView.delegate = self
        
        let url : NSURL?
        if urltaken != ""{
                url = NSURL(string: urltaken)
            self.showActivityIndicator(true)
                let urlRequest = NSURLRequest(URL: url!)
                webView.loadRequest(urlRequest)
        }
        
            
        
}
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
       // webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showActivityIndicator(wantToShow : Bool){
        activityIndicator.frame = CGRectMake(0, 0, 40.0, 40.0)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .Gray
        self.view.addSubview(activityIndicator)
        if wantToShow == true{
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }
    


  
}

extension TermsAndConditionsPDFViewController : UIWebViewDelegate{
    
    func webViewDidFinishLoad(webView: UIWebView){
            self.showActivityIndicator(false)
    }
}
