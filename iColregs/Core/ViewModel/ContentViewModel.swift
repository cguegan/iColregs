//
//  ContentViewModel.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import Foundation

final class ContentViewModel: ObservableObject {
    
    @Published var colregs: ColregsModel?
    let jsonFileName = "colregs"
    
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
        if let jsonData = readLocalJSONFile(forName: jsonFileName),
           let colregs = parseJsonData(jsonData: jsonData){
            self.colregs = colregs
            print("colregs: \(colregs)")
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
            print("error: \(error)")
        }
        return nil
    }
    
    /// Parse Json data
    /// - Parameter jsonData: raw Json data returned from the file
    /// - Returns: decoded data

    func parseJsonData(jsonData: Data) -> ColregsModel? {
        do {
            let decodedData = try JSONDecoder().decode(ColregsModel.self, from: jsonData)
            return decodedData
        } catch {
            print("error: \(error)")
        }
        return nil
    }
}
