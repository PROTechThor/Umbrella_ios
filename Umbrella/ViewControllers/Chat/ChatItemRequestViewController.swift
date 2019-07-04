//
//  ChatItemRequestViewController.swift
//  Umbrella
//
//  Created by Lucas Correa on 01/07/2019.
//  Copyright © 2019 Security First. All rights reserved.
//

import UIKit

class ChatItemRequestViewController: UIViewController {
    
    //
    // MARK: - Properties
    @IBOutlet weak var sendBottomConstraint: NSLayoutConstraint!
    lazy var chatItemRequestViewModel: ChatItemRequestViewModel = {
        let chatItemRequestViewModel = ChatItemRequestViewModel()
        return chatItemRequestViewModel
    }()
    
    lazy var chatMessageViewModel: ChatMessageViewModel = {
        let chatMessageViewModel = ChatMessageViewModel()
        return chatMessageViewModel
    }()
    
    @IBOutlet weak var sendButton: UIButton!
    var itemSelected: [IndexPath] = [IndexPath]() {
        didSet {
            if itemSelected.count > 0 {
                self.sendButton.setTitle("Send", for: .normal)
                self.sendBottomConstraint.constant = 44
            } else {
                self.sendButton.setTitle("", for: .normal)
                self.sendBottomConstraint.constant = 0
            }
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 300, height: 250)
        
        self.title = self.chatItemRequestViewModel.item.name
    }
    
    @IBAction func sendAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        switch self.chatItemRequestViewModel.item.type {
        case .forms:
            if itemSelected.count > 0 {
                
                let shareItem = self.prepareHtml(indexPath: self.itemSelected.first!)
                let filename = shareItem.nameFile + ".pdf"
                let pdf = PDF(nameFile: filename, content: shareItem.content)
                let export = Export(pdf)
                let url = export.makeExport()
                
                DispatchQueue.global(qos: .background).async {
                    self.chatItemRequestViewModel.uploadFile(filename: filename, fileURL: url, success: { (response) in
                        
                        guard let url = response as? String else {
                            print("Error cast response to String")
                            return
                        }
                        
                        self.chatMessageViewModel.sendMessage(messageType: .file,
                                                              message: filename,
                                                              url: url,
                                                              success: { _ in
                                                                
                        }, failure: { (response, object, error) in
                            print(error ?? "")
                        })
                    }, failure: { (response, object, error) in
                        print(error ?? "")
                    })
                }
            }
        case .checklists:
            break
        case .answers:
            break
        default:
            break
        }
        
    }
    
    /// Add the text tag html on string
    ///
    /// - Parameters:
    ///   - item: ItemForm
    ///   - html: String
    ///   - formAnswers: Array of FormAnswer
    fileprivate func htmlAddTextInput(_ item: ItemForm, _ html: inout String, _ formAnswers: [FormAnswer]) {
        var text = ""
        for formAnswer in formAnswers where formAnswer.itemFormId == item.id {
            text = formAnswer.text
        }
        html += "<input type=\"text\" value=\"\(text)\" readonly /> \n"
    }
    
    /// Add the textarea tag html on string
    ///
    /// - Parameters:
    ///   - item: ItemForm
    ///   - html: String
    ///   - formAnswers: Array of FormAnswer
    fileprivate func htmlAddTextArea(_ item: ItemForm, _ html: inout String, _ formAnswers: [FormAnswer]) {
        var text = ""
        for formAnswer in formAnswers where formAnswer.itemFormId == item.id {
            text = formAnswer.text
        }
        html += "<textarea rows=\"4\" cols=\"50\" readonly>\(text)</textarea> \n"
    }
    
    /// Add the checkbox tag html on string
    ///
    /// - Parameters:
    ///   - item: ItemForm
    ///   - html: String
    ///   - formAnswers: Array of FormAnswer
    fileprivate func htmlAddMultiChoice(_ item: ItemForm, _ html: inout String, _ formAnswers: [FormAnswer]) {
        for optionItem in item.options {
            var boolean = false
            for formAnswer in formAnswers where formAnswer.itemFormId == item.id && formAnswer.optionItemId == optionItem.id {
                boolean = true
            }
            html += "<label><input type=\"checkbox\"\(boolean ? "checked" : "") readonly onclick=\"return false;\">\(optionItem.label)</label><br> \n"
        }
    }
    
    /// Add the radio tag html on string
    ///
    /// - Parameters:
    ///   - item: ItemForm
    ///   - html: String
    ///   - formAnswers: Array of FormAnswer
    fileprivate func htmlAddSingleChoice(_ item: ItemForm, _ html: inout String, _ formAnswers: [FormAnswer]) {
        for optionItem in item.options {
            var boolean = false
            for formAnswer in formAnswers where formAnswer.itemFormId == item.id && formAnswer.optionItemId == optionItem.id {
                boolean = true
            }
            html += "<label><input type=\"radio\"\(boolean ? "checked" : "") readonly onclick=\"return false;\">\(optionItem.label)</label><br> \n"
        }
    }
    
    /// Prepare the File.html to be share
    ///
    /// - Parameters:
    ///   - indexPath: IndexPath
    /// - Returns: String
    func prepareHtml(indexPath: IndexPath) -> (nameFile: String, content: String) {
        
        var formAnswer = FormAnswer()
        var form = Form()
        var formAnswers: [FormAnswer] = [FormAnswer]()
        
        if indexPath.section == 0 {
            form = self.chatItemRequestViewModel.umbrella.loadFormByCurrentLanguage()[indexPath.row]
        } else if indexPath.section == 1 {
            formAnswer = self.chatItemRequestViewModel.umbrella.loadFormAnswersByCurrentLanguage()[indexPath.row]
            
            for formResult in self.chatItemRequestViewModel.umbrella.loadFormByCurrentLanguage() where formAnswer.formId == formResult.id {
                form = formResult
            }
            
            formAnswers = self.chatItemRequestViewModel.loadFormAnswersTo(formAnswerId: formAnswer.formAnswerId, formId: form.id)
        }
        
        var html: String = ""
        
        html += """
        <html>
        <head>
        <meta charset="UTF-8"> \n
        """
        html += "<title>\(form.name)</title> \n"
        html += "</head> \n"
        html += "<body style=\"display:block;width:100%;\"> \n"
        html += "<h1>\(form.name)</h1> \n"
        
        for screen in form.screens {
            html += "<h3>\(screen.name)</h3> \n"
            html += "<form> \n"
            
            for item in screen.items {
                html += "<p></p> \n"
                html += "<h5>\(item.label)</h5> \n"
                
                switch item.formType {
                    
                case .textInput:
                    htmlAddTextInput(item, &html, formAnswers)
                case .textArea:
                    htmlAddTextArea(item, &html, formAnswers)
                case .multiChoice:
                    htmlAddMultiChoice(item, &html, formAnswers)
                case .singleChoice:
                    htmlAddSingleChoice(item, &html, formAnswers)
                case .label:
                    break
                case .none:
                    break
                }
            }
        }
        
        html += """
        </form>
        </body>
        </html>
        """
        return (form.name.replacingOccurrences(of: " ", with: "_"), html)
    }
    
}

// MARK: - UITableViewDataSource
extension ChatItemRequestViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch self.chatItemRequestViewModel.item.type {
        case .forms:
            if self.chatItemRequestViewModel.umbrella.loadFormAnswersByCurrentLanguage().count > 0 {
                return 2
            }
            return 1
        case .checklists:
            return 1
        case .answers:
            return 1
        default:
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.chatItemRequestViewModel.item.type {
        case .forms:
            if self.chatItemRequestViewModel.umbrella.loadFormAnswersByCurrentLanguage().count > 0 {
                if section == 0 {
                    return self.chatItemRequestViewModel.umbrella.loadFormByCurrentLanguage().count
                } else if section == 1 {
                    return self.chatItemRequestViewModel.umbrella.loadFormAnswersByCurrentLanguage().count
                }
            }
            
            return self.chatItemRequestViewModel.umbrella.loadFormByCurrentLanguage().count
        case .checklists:
            return self.chatItemRequestViewModel.checklists.count
        case .answers:
            return 0
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatItemRequestCell = (tableView.dequeueReusableCell(withIdentifier: "ChatItemRequestCell", for: indexPath) as? ChatItemRequestCell)!
        cell.configure(withViewModel: self.chatItemRequestViewModel, indexPath: indexPath)
        cell.iconImageView.image = itemSelected.contains(indexPath) ? #imageLiteral(resourceName: "checkSelected") : #imageLiteral(resourceName: "groupNormal")
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ChatItemRequestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch self.chatItemRequestViewModel.item.type {
        case .forms:
            return 30
        case .checklists:
            return 0
        case .answers:
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 30))
        label.font = UIFont.init(name: "SFProText-SemiBold", size: 12)
        label.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        if self.chatItemRequestViewModel.umbrella.loadFormAnswersByCurrentLanguage().count > 0 {
            if section == 0 {
                label.text = "Available forms".localized()
            } else if section == 1 {
                label.text = "Active".localized()
            }
        } else {
            label.text = "Available forms".localized()
        }
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemSelected.removeAll()
        itemSelected.append(indexPath)
        tableView.reloadData()
    }
}
