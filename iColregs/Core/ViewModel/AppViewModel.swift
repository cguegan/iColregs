//
//  ContentViewModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation

final class AppViewModel: ObservableObject {
    
    @Published var colregs: ColregsModel?
    @Published var annexes: AnnexesModel?
    @Published var ripam: RipamModel?
    
    let jsonFileName = "colregs"
    let annexFileName = "annexes"
    let ripamFileName = "ripam"
    
    // MARK: - Init
    // ————————————
    
    init() {
        self.fetchData()
    }
    
    // MARK: - Methods
    // ———————————————
    
    /// Fetch data
    /// Load Json file when the main screen appears
    
    func fetchData() {
        if let colregsJsonData = readLocalJSONFile(forName: jsonFileName),
           let colregs = parseColregsData(jsonData: colregsJsonData){
            self.colregs = colregs
        }
        if let annexJsonData = readLocalJSONFile(forName: annexFileName),
           let annexes = parseAnnexesData(jsonData: annexJsonData){
            self.annexes = annexes
        }
        if let ripamJsonData = readLocalJSONFile(forName: ripamFileName),
           let ripam = parseRipamData(jsonData: ripamJsonData){
            self.ripam = ripam
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
    
    /// Parse Annexes data
    /// - Parameter jsonData: raw Json data returned from the file
    /// - Returns: decoded data

    func parseAnnexesData(jsonData: Data) -> AnnexesModel? {
        do {
            let decodedData = try JSONDecoder().decode(AnnexesModel.self, from: jsonData)
            return decodedData
        } catch {
            print("ERROR: \(error)")
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
