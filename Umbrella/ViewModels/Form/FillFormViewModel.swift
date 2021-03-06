//
//  FillFormViewModel.swift
//  Umbrella
//
//  Created by Lucas Correa on 24/07/2018.
//  Copyright © 2018 Security First. All rights reserved.
//

import Foundation

class FillFormViewModel {
    
    //
    // MARK: - Properties
    var form: Form
    var formAnswer: FormAnswer
    var sqlManager: SQLManager
    lazy var formAnswerDao: FormAnswerDao = {
        let formAnswerDao = FormAnswerDao(sqlProtocol: self.sqlManager)
        return formAnswerDao
    }()
    
    //
    // MARK: - Init
    init() {
        self.form = Form()
        self.formAnswer = FormAnswer()
        self.sqlManager = SQLManager(databaseName: Database.name, password: Database.password)
    }
    
    //
    // MARK: - Functions
    func formAnswerId() -> Int64 {
        return formAnswerDao.lastFormAnswerId()
    }
    
    /// Load the formAnswers
    ///
    /// - Parameters:
    ///   - formId: Int
    /// - Returns: Array of FormAnswer
    func loadFormAnswersTo(formId: Int) -> [FormAnswer] {
        return formAnswerDao.listFormAnswers(at: Int64(formAnswer.formAnswerId), formId: Int64(formId))
    }
}
