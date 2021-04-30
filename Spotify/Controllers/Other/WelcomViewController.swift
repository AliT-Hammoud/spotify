//
//  WelcomViewController.swift
//  Spotify
//
//  Created by Ali Hammoud on 4/30/21.
//

import UIKit

class WelcomViewController: UIViewController {

    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotify"
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTabSignIn), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let yAxis = view.height-50-view.safeAreaInsets.bottom
        signInButton.frame = CGRect(x: 20,
                                    y: yAxis,
                                    width: view.width - 40,
                                    height: 50)
    }
    
    @objc func didTabSignIn(){
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func handleSignIn(success: Bool) {
        
    }
}
