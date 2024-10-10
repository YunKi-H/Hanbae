//
//  TempMainView.swift
//  Macro
//
//  Created by Yunki on 10/9/24.
//

import SwiftUI

struct TempMainView: View {
    @State var viewModel: TempMainViewModel = .init()
    
    private func heightCalc(_ accent: Accent) -> CGFloat {
        switch accent {
        case .none:
            return 0
        case .weak:
            return 50
        case .medium:
            return 100
        case .strong:
            return 150
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                ForEach(0..<12) { index in
                    let daebak = index / viewModel.state.jangdanAccents[0].count // 3
                    let sobak = index % viewModel.state.jangdanAccents[0].count // 3
                    
                    Button {
                        self.viewModel.effect(action: .changeAccent(daebak: daebak, sobak: sobak))
                    } label: {
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(index == viewModel.state.currentIndex ? Color.red : Color.blue)
                                .frame(width: 20, height: heightCalc(viewModel.state.jangdanAccents[daebak][sobak]))
                        }
                        .frame(width: 20, height: 150)
                    }
                }
            }
            .padding()
            
            Button(viewModel.state.isPlaying ? "Stop" : "Play") {
                viewModel.effect(action: .playButton)
            }
            .padding()
            
            HStack {
                Button("-") {
                    viewModel.effect(action: .decreaseBpm)
                }
                Text("\(viewModel.state.bpm)")
                Button("+") {
                    viewModel.effect(action: .increaseBpm)
                }
            }
            .padding()
        }
    }
}

@Observable
class TempMainViewModel {
    private var templateUseCase: TemplateUseCase
    private var metronomeOnOffUseCase: MetronomeOnOffUseCase
    private var tempoUseCase: TempoUseCase
    private var accentUseCase : AccentUseCase
    
    init() {
        let initTemplateUseCase: TemplateUseCase = .init()
        let initSoundManager: SoundManager? = .init()
        
        initTemplateUseCase.setJangdan(name: "자진모리")
        
        self.templateUseCase = initTemplateUseCase
        self.metronomeOnOffUseCase = .init(templateUseCase: initTemplateUseCase, soundManager: initSoundManager!)
        self.tempoUseCase = .init(templateUseCase: initTemplateUseCase)
        self.accentUseCase = .init(templateUseCase: initTemplateUseCase)
    }
    
    struct State {
        var isPlaying: Bool = false
        var currentIndex: Int = -1
        var bpm: Int = 60
        var jangdanAccents: [[Accent]] = [
            [.strong, .weak, .weak],
            [.strong, .weak, .weak],
            [.strong, .weak, .weak],
            [.strong, .weak, .weak]
        ]
    }
    
    private var _state: State = .init()
    var state: State { return _state }
    
    enum Action {
        case playButton // Play / Stop Button
        case decreaseBpm // - button
        case increaseBpm // + button
        case changeAccent(daebak: Int, sobak: Int)
    }
    
    func effect(action: Action) {
        switch action {
        case .playButton:
            self._state.currentIndex = -1
            self._state.isPlaying.toggle()
            
            if self._state.isPlaying {
                self.metronomeOnOffUseCase.play {
                    self._state.currentIndex += 1
                    self._state.currentIndex %= self.templateUseCase.currentJangdanBakCount
                }
            } else {
                self.metronomeOnOffUseCase.stop()
            }
            
        case .decreaseBpm:
            self._state.bpm -= 10
            self.tempoUseCase.updateTempo(newBpm: self._state.bpm)
            
        case .increaseBpm:
            self._state.bpm += 10
            self.tempoUseCase.updateTempo(newBpm: self._state.bpm)
            
        case let .changeAccent(daebak, sobak):
            self.accentUseCase.moveNextAccent(daebakIndex: daebak, sobakIndex: sobak)
            self._state.jangdanAccents[daebak][sobak] = self._state.jangdanAccents[daebak][sobak].nextAccent()
        }
    }
}

#Preview {
    TempMainView()
}
