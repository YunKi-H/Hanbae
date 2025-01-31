//
//  HomeViewModel.swift
//  Macro
//
//  Created by leejina on 11/21/24.
//

import SwiftUI
import Combine

@Observable
class HomeViewModel {
    
    private var metronomeOnOffUseCase: MetronomeOnOffUseCase
    private var dynamicIconUseCase: DynamicIconUseCase
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(metronomeOnOffUseCase: MetronomeOnOffUseCase, dynamicIconUseCase: DynamicIconUseCase) {
        self.metronomeOnOffUseCase = metronomeOnOffUseCase
        self.dynamicIconUseCase = dynamicIconUseCase
        
        self.metronomeOnOffUseCase.firstTickPublisher.sink { [weak self] _ in
            guard let self else { return }
            self.state.isBlinkOn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.state.isBlinkOn = false
            }
        }
        .store(in: &cancelBag)
    }
    
    private(set) var state: State = .init()
    
    struct State {
        var isBlinkOn: Bool = false
    }
}

extension HomeViewModel {
    enum Action {
        case changeSoundType
        case appEntered
    }
    
    func effect(action: Action) {
        switch action {
        case .changeSoundType:
            self.metronomeOnOffUseCase.setSoundType()
        case .appEntered:
            self.dynamicIconUseCase.setEventIconIfNeeded()
        }
    }
}
