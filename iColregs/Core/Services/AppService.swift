//
//  AppService.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation
import Observation

/// Supported languages
/// - en: English
/// - fr: French
/// - id: language code
///
enum Language: String, Codable, CaseIterable, Identifiable {
  case en = "EN"
  case fr = "FR"
  
  var id: String { self.rawValue }
}

@Observable
final class AppService {
    
    var colregs: ColregsModel?
    var annexesEn: ColregsModel?
    var ripam: RipamModel?
    var annexesFr: RipamModel?

    let jsonFileName = "colregs"
    let annexEnFileName = "annexes_en"
    let ripamFileName = "ripam"
    let annexFrFileName = "annexes_fr"

    /// Initializer
    init() {
        self.fetchData()
    }
    
    // MARK: - Methods
    // ———————————————
    
    /// Fetch data
    /// Load Json file when the main screen appears
    
    func fetchData() {
        
        // En COLREGS
        
        if let colregsJsonData = readLocalJSONFile(forName: jsonFileName),
           let colregs = parseColregsData(jsonData: colregsJsonData) {
            self.colregs = colregs
        }
        
        if let annexJsonData = readLocalJSONFile(forName: annexEnFileName),
           let annexes = parseColregsData(jsonData: annexJsonData) {
            self.annexesEn = annexes
        }
        
        // French RIPAM
        
        if let ripamJsonData = readLocalJSONFile(forName: ripamFileName),
           let ripam = parseRipamData(jsonData: ripamJsonData) {
            self.ripam = ripam
        }
        
        if let annexFrJsonData = readLocalJSONFile(forName: annexFrFileName),
           let annexesFr = parseRipamData(jsonData: annexFrJsonData) {
            self.annexesFr = annexesFr
        }
    }
    
    /// Read json file from main bundle (i.e: the file structure distribured with the app)
    /// - Parameter name: name of the json file
    /// - Returns: raw data from the file

    func readLocalJSONFile(forName name: String) -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            }
        } catch {
            print("ERROR: \(error)")
        }
        return nil
    }
    
    /// Parse Colregs data
    /// - Parameter jsonData: raw Json data returned from the file
    /// - Returns: decoded data

    func parseColregsData(jsonData: Data) -> ColregsModel? {
        do {
            let decodedData = try JSONDecoder().decode(ColregsModel.self, from: jsonData)
            return decodedData
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    
    /// Parse Ripam data
    /// - Parameter jsonData: raw Json data returned from the file
    /// - Returns: decoded data

    func parseRipamData(jsonData: Data) -> RipamModel? {
        do {
            let decodedData = try JSONDecoder().decode(RipamModel.self, from: jsonData)
            return decodedData
        } catch {
            print("ERROR: \(error)")
        }
        return nil
    }

}
