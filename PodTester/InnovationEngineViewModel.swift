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
        
    private var innovationEngine: InnovationEngine
    
    
    var loaderServer: String? {
        innovationEngine.configLoaderServer
    }
    
    override init() {
        innovationEngine = InnovationEngine.shared
        
        let loaderServer = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_LOADER_SERVER") as? String ?? ""
        innovationEngine.configLoaderServer = !loaderServer.isEmpty ? loaderServer : "https://your-instance.innovation-club.net"
    }
    
    
    func configureClientId(_ clientId: String) {
        innovationEngine.configClientId = clientId
    }
    
    func configureEnvironment(_ environment: String) {
        innovationEngine.configEnvironment = environment
    }
    
    func configureTimeout(_ timeout: String) {
        innovationEngine.configTimeout = Int(timeout) ?? 500
    }
    
    
    func getExperiments(completion: @escaping (Result<[Experiment?], Error>) -> Void) {
        innovationEngine.getExperiments(screenIds: [screenId]) { result in
            completion(result)
            /*
            switch result {
            case .failure(let error):
                // handle the error
                print("\(error)")

            case .success(let experiments):
                // This example only considers the first entry of the array of Experiments
                guard let experiment = experiments[0] else {
                    print("No experiment returned")
//                    DispatchQueue.main.async {
//                        self.viewModel.setError("No experiment returned")
//                    }
                    return
                }
                // start the experiment
                print("experiments[0] \(experiment)")
//                self.startExperiment(experiment)
            }
             */
        }
    }
}
