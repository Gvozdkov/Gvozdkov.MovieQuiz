//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Алексей Гвоздков on 17.04.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        
        continueAfterFailure = false  // специальная настройка для тестов: если один тест не прошел, то следующий тест не будет запускаться
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    
 
    func testScreenCast() throws {

    }
}
