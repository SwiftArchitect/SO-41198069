//
//  ViewController.swift
//  SO-41198069
//
//  Copyright © 2017, 2018 Xavier Schott
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

let sizeConstant: CGFloat = 60

class ViewController: UIViewController {

    let topView = UIView()
    let backgroundView = UIView()
    let stackView = UIStackView()
    let lLayoutGuide = UILayoutGuide()
    let bLayoutGuide = UILayoutGuide()
    var bottomConstraints = [NSLayoutConstraint]()
    var leftConstraints = [NSLayoutConstraint]()

    var bLayoutHeightConstraint: NSLayoutConstraint!
    var lLayoutWidthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {

        super.viewDidLoad()

        print(UIScreen.main.bounds)

        //        self.view.layer.masksToBounds = true

        let views = [
            UIButton(type: .infoDark),
            UIButton(type: .contactAdd),
            UIButton(type: .detailDisclosure)
        ]
        views.forEach(self.stackView.addArrangedSubview)

        self.backgroundView.backgroundColor = UIColor.red
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.backgroundView)

        self.topView.backgroundColor = UIColor.green
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.topView)

        self.stackView.axis = isPortrait() ? .horizontal : .vertical
        self.stackView.distribution = .fillEqually
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.addSubview(self.stackView)

        self.topView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true

        self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.topView.heightAnchor.constraint(equalToConstant: 46).isActive = true

        self.view.addLayoutGuide(self.lLayoutGuide)
        self.view.addLayoutGuide(self.bLayoutGuide)

        self.bLayoutGuide.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.bLayoutGuide.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.bLayoutGuide.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.bLayoutHeightConstraint = self.bLayoutGuide.heightAnchor.constraint(equalToConstant: isPortrait() ? sizeConstant : 0)
        self.bLayoutHeightConstraint.isActive = true

        self.lLayoutGuide.topAnchor.constraint(equalTo: self.topView.bottomAnchor).isActive = true
        self.lLayoutGuide.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.lLayoutGuide.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.lLayoutWidthConstraint = self.lLayoutGuide.widthAnchor.constraint(equalToConstant: isPortrait() ? 0 : sizeConstant)
        self.lLayoutWidthConstraint.isActive = true

        self.stackView.topAnchor.constraint(equalTo: self.backgroundView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor).isActive = true

        self.bottomConstraints = [
            self.backgroundView.topAnchor.constraint(equalTo: self.bLayoutGuide.topAnchor),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.bLayoutGuide.leadingAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.bLayoutGuide.trailingAnchor),
            self.backgroundView.heightAnchor.constraint(equalToConstant: sizeConstant)
        ]

        self.leftConstraints = [
            self.backgroundView.topAnchor.constraint(equalTo: self.lLayoutGuide.topAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.lLayoutGuide.bottomAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.lLayoutGuide.trailingAnchor),
            self.backgroundView.widthAnchor.constraint(equalToConstant: sizeConstant)
        ]

        if isPortrait() {

            NSLayoutConstraint.activate(self.bottomConstraints)

        } else {

            NSLayoutConstraint.activate(self.leftConstraints)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        let willBePortrait = size.width < size.height

        coordinator.animate(alongsideTransition: {

            context in

            let halfDuration = context.transitionDuration / 2.0

            UIView.animate(withDuration: halfDuration, delay: 0, options: .overrideInheritedDuration, animations: {

                self.bLayoutHeightConstraint.constant = 0
                self.lLayoutWidthConstraint.constant = 0
                self.view.layoutIfNeeded()

            }, completion: {

                _ in

                // HERE IS THE ISSUE!

                // Putting this inside `performWithoutAnimation` did not helped
                if willBePortrait {

                    self.stackView.axis = .horizontal
                    NSLayoutConstraint.deactivate(self.leftConstraints)
                    NSLayoutConstraint.activate(self.bottomConstraints)

                } else {

                    self.stackView.axis = .vertical
                    NSLayoutConstraint.deactivate(self.bottomConstraints)
                    NSLayoutConstraint.activate(self.leftConstraints)
                }
                self.view.layoutIfNeeded()

                UIView.animate(withDuration: halfDuration) {

                    if willBePortrait {

                        self.bLayoutHeightConstraint.constant = sizeConstant

                    } else {
                        
                        self.lLayoutWidthConstraint.constant = sizeConstant
                    }
                    self.view.layoutIfNeeded()
                }
            })
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func isPortrait() -> Bool {
        
        let size = UIScreen.main.bounds.size
        return size.width < size.height
    }
}

