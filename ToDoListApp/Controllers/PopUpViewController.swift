//
//  PopUpViewController.swift
//  ToDoListApp
//
//  Created by Taso Grigoriou on 10/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

protocol PopUpViewControllerDelegate: class {
    func createNewTask(name: String)
    func updateTask(_ task: Task, newName: String)
}

class PopUpViewController: UIViewController {
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    
    private var task: Task?
    
    weak var delegate: PopUpViewControllerDelegate?
    
    init(task: Task? = nil, delegate: PopUpViewControllerDelegate? = nil) {
        self.task = task
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextField()
        setupTapRecognizer()
        setUpKeyboardObserver()
    }
    
    private func setupView() {
        popUpView.layer.cornerRadius = 5
        popUpView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func setupTextField() {
        if let task = task {
            textField.text = task.name
        }
        textField.becomeFirstResponder()
    }
    
    private func setupTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    private func setUpKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func saveTask() {
        if let text = textField.text, !text.isEmpty {
            if let task = task {
                delegate?.updateTask(task, newName: text)
            } else {
                delegate?.createNewTask(name: text)
            }
        }
        dismissVC()
    }
    
    @IBAction func saveButtonPressed() {
        saveTask()
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let totalHeight = keyboardFrame.cgRectValue.height + textField.frame.height + 16
        topViewConstraint.constant = view.frame.height - totalHeight
    }
    
    @objc private func dismissVC() {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}

extension PopUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.textField.text = textField.text
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveTask()
        return true
    }
}

extension PopUpViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let location: CGPoint = gestureRecognizer.location(in: view)
            return !popUpView.frame.contains(location)
        }
        return false
    }
}
