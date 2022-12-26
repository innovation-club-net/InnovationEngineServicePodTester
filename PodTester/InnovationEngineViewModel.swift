//
//  InnovationEngineViewModel.swift
//  PodTester
//
//  Created by Fred on 23.12.22.
//

import Foundation
import InnovationEngineService

class InnovationEngineViewModel: NSObject, ObservableObject {
    
    @Published var screenId: String = ""
        
    var innovationEngine: InnovationEngine
    

    override init() {
        innovationEngine = InnovationEngine.shared
        
        let loaderServer = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_LOADER_SERVER") as? String ?? ""
        innovationEngine.configLoaderServer = !loaderServer.isEmpty ? loaderServer : "https://your-instance.innovation-club.net"
        
        let environment = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_ENVIRONMENT") as? String ?? ""
        innovationEngine.configEnvironment = !environment.isEmpty ? environment : "dev"
        
        let timeout = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_TIMEOUT") as? String ?? ""
        innovationEngine.configTimeout = !timeout.isEmpty ? Int(timeout) ?? 500 : 500
    }
    
    
    ///
    ///
    func configureClientId(_ clientId: String) {
        innovationEngine.configClientId = clientId
    }
    
    
    ///
    ///
    func getExperiments(completion: @escaping (Result<[Experiment?], Error>) -> Void) {
        innovationEngine.getExperiments(screenIds: [screenId]) { result in
            completion(result)
        }
    }
    
    
    ///
    ///
    static func getMessageForError(_ error: Error) -> String {
        switch error as? RequestError {
        case .error(let error):
            return error.localizedDescription
        case .parsing:
            return "InnovationEngine parsing failed"
        case .webPageEmpty:
            return "InnovationEngine web page is empty"
        case .none:
            fatalError("InnovationEngine request failed \n error in wrong format")
        }
    }

}
