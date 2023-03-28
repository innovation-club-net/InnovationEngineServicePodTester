//
//  ExperimentView.swift
//  PodTester
//
//  Created by Fred on 25.12.22.
//

import Foundation
import SwiftUI
import InnovationEngineService

class ExperimentViewController: UIViewController {
    
    var experiment: Experiment
    var completion: (Result<CloseEvent, Error>) -> Void

    init(experiment: Experiment, completion: @escaping (Result<CloseEvent, Error>) -> Void) {
        self.experiment = experiment
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        experiment.startWebView(inside: self.view, completion: completion)
    }
    
    
}


struct ExperimentView: UIViewControllerRepresentable {
    
    var experiment: Experiment
    var completion: (Result<CloseEvent, Error>) -> Void
    
    ///
    ///
    func makeUIViewController(context: Context) -> ExperimentViewController {
        return ExperimentViewController(experiment: experiment, completion: completion)
    }

    
    ///
    ///
    func updateUIViewController(_ uiViewController: ExperimentViewController, context: Context) {
        
    }
    
    
}
