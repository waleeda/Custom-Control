//
//  ViewController.swift
//  CustomControl
//
//  Created by waleed azhar on 2017-04-03.
//  Copyright © 2017 waleed azhar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let control = UISelectionControl(frame: CGRect.zero, nullSegment: false, with: 10, colors: [.red,.yellow,.blue,.gray,
                                                                                                UIColor(red:0.13, green:0.70, blue:0.93, alpha:1.00),UIColor(red:0.49, green:0.74, blue:0.73, alpha:1.00),UIColor(red:0.02, green:0.20, blue:0.39, alpha:1.00),UIColor(red:1.00, green:0.79, blue:0.02, alpha:1.00),UIColor(red:0.58, green:0.07, blue:0.36, alpha:1.00),UIColor(red:0.31, green:0.44, blue:0.55, alpha:1.00)])
    let label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.brown
        control?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(control!)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            (control?.centerXAnchor.constraint(equalTo: view.centerXAnchor))!,
            (control?.centerYAnchor.constraint(equalTo: view.centerYAnchor))!,
            label.topAnchor.constraint(equalTo: view.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        control?.addTarget(self, action: #selector(selected(c:)), for: .valueChanged)
    }
    
    @objc func selected(c:UISelectionControl){
       label.text = String(c.selectedSegment)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

