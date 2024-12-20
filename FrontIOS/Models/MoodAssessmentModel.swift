//
//  MoodAssessmentModel.swift
//  FrontIOS
//
//  Created by guesmiFiras on 28/11/2024.
//

import Foundation


struct UserType: Codable {
    let userType: String
}


    
    enum CodingKeys: String, CodingKey {
        case userType
    }


