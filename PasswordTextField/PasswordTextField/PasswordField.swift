//
//  PasswordField.swift
//  PasswordTextField
//
//  Created by Ben Gohlke on 6/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum strengthLevel {
    case weak
    case medium
    case strong
}


class PasswordField: UIControl {
    
    // Public API - these properties are used to fetch the final password and strength values
    private var hiddenPassword = true
    private (set) var password: String = ""
    private (set) var strength: strengthLevel = .weak
    
    private let standardMargin: CGFloat = 8.0
    private let textFieldContainerHeight: CGFloat = 50.0
    private let textFieldMargin: CGFloat = 6.0
    private let colorViewSize: CGSize = CGSize(width: 60.0, height: 5.0)
    
    private let labelTextColor = UIColor(hue: 233.0/360.0, saturation: 16/100.0, brightness: 41/100.0, alpha: 1)
    private let labelFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    
    private let textFieldBorderColor = UIColor(hue: 208/360.0, saturation: 80/100.0, brightness: 94/100.0, alpha: 1)
    private let bgColor = UIColor(hue: 0, saturation: 0, brightness: 97/100.0, alpha: 1)
    
    // States of the password strength indicators
    private let unusedColor = UIColor(hue: 210/360.0, saturation: 5/100.0, brightness: 86/100.0, alpha: 1)
    private let weakColor = UIColor(hue: 0/360, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let mediumColor = UIColor(hue: 39/360.0, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let strongColor = UIColor(hue: 132/360.0, saturation: 60/100.0, brightness: 75/100.0, alpha: 1)
    
    
    // MARK: - UI Element Properties
    private var titleLabel: UILabel = UILabel()
    private var textField: UITextField = UITextField()
    private var showHideButton: UIButton = UIButton()
    private var weakView: UIView = UIView()
    private var mediumView: UIView = UIView()
    private var strongView: UIView = UIView()
    private var strengthDescriptionLabel: UILabel = UILabel()
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
    override var intrinsicContentSize: CGSize {
        let height = standardMargin * 4 + labelFont.lineHeight + textFieldContainerHeight + strengthDescriptionLabel.font.lineHeight
        let width = UIScreen.main.bounds.width - standardMargin * 2 - CGFloat(10 * 2)
        
        return CGSize(width: width, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        self.textField.delegate = self
    }
    
    
    // MARK: - Add UI Element Subviews
    func setup() {
        self.backgroundColor = bgColor
        // Enter password label
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ENTER PASSWORD"
        titleLabel.textColor = labelTextColor
        titleLabel.font = labelFont
        
        titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: standardMargin).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: standardMargin).isActive = true
        
        // Password text field
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.bounds.inset(by: UIEdgeInsets(top: textFieldMargin, left: textFieldMargin, bottom: textFieldMargin, right: textFieldMargin))
        textField.layer.borderWidth = 1
        textField.layer.borderColor = textFieldBorderColor.cgColor
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.placeholder = "Type in a password"
        if hiddenPassword {
            textField.isSecureTextEntry = true
        } else {
            textField.isSecureTextEntry = false
        }
        
        textField.heightAnchor.constraint(equalToConstant: textFieldContainerHeight).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: standardMargin).isActive = true
        textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standardMargin).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -standardMargin).isActive = true
        
        
        // Show-hide button
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        if hiddenPassword {
            let buttonImage = UIImage(named: "eyes-closed")
            showHideButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "eyes-open")
            showHideButton.setImage(buttonImage, for: .normal)
        }
        showHideButton.addTarget(self, action: #selector(self.toggleButton), for: .touchUpInside)
        addSubview(showHideButton)
        
        showHideButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -standardMargin).isActive = true
        showHideButton.topAnchor.constraint(equalTo: textField.topAnchor, constant: textFieldMargin).isActive = true
        showHideButton.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: -textFieldMargin).isActive = true
        
        // Password strength indicators
        addSubview(weakView)
        weakView.translatesAutoresizingMaskIntoConstraints = false
        weakView.layer.backgroundColor = weakColor.cgColor
        weakView.heightAnchor.constraint(equalToConstant: colorViewSize.height).isActive = true
        weakView.widthAnchor.constraint(equalToConstant: colorViewSize.width).isActive = true


        addSubview(mediumView)
        mediumView.translatesAutoresizingMaskIntoConstraints = false
        mediumView.layer.backgroundColor = unusedColor.cgColor
        mediumView.heightAnchor.constraint(equalToConstant: colorViewSize.height).isActive = true
        mediumView.widthAnchor.constraint(equalToConstant: colorViewSize.width).isActive = true

        mediumView.leadingAnchor.constraint(equalTo: weakView.trailingAnchor, constant: 2).isActive = true


        addSubview(strongView)
        strongView.translatesAutoresizingMaskIntoConstraints = false
        strongView.layer.backgroundColor = unusedColor.cgColor
        strongView.heightAnchor.constraint(equalToConstant: colorViewSize.height).isActive = true
        strongView.widthAnchor.constraint(equalToConstant: colorViewSize.width).isActive = true

        strongView.leadingAnchor.constraint(equalTo: mediumView.trailingAnchor, constant: 2).isActive = true

        
        // Strength label
        addSubview(strengthDescriptionLabel)
        strengthDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        strengthDescriptionLabel.text = "Too weak"
        strengthDescriptionLabel.textColor = labelTextColor
        strengthDescriptionLabel.font = labelFont
        
        strengthDescriptionLabel.leadingAnchor.constraint(equalTo: strongView.trailingAnchor, constant: standardMargin).isActive = true
        
        let stackView = UIStackView()
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        
        stackView.addArrangedSubview(weakView)
        stackView.addArrangedSubview(mediumView)
        stackView.addArrangedSubview(strongView)
        stackView.addArrangedSubview(strengthDescriptionLabel)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standardMargin),
            stackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: standardMargin),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standardMargin)
        ])
    }

    
    @objc func toggleButton(sender: UIButton!) {
        if hiddenPassword {
            hiddenPassword.toggle()
            let buttonImage = UIImage(named: "eyes-open")
            showHideButton.setImage(buttonImage, for: .normal)
            textField.isSecureTextEntry = false
        } else {
            hiddenPassword.toggle()
            let buttonImage = UIImage(named: "eyes-closed")
            showHideButton.setImage(buttonImage, for: .normal)
            textField.isSecureTextEntry = true
        }
    }
}

extension PasswordField: UITextFieldDelegate {
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        // TODO: send new text to the determine strength method
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        if let newPassword = textField.text,
            !newPassword.isEmpty {
        self.password = newPassword
        sendActions(for: .valueChanged)
        return false
        } else { return true }
    }
    
}
