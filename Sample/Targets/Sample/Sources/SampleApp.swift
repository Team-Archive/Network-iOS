
import SwiftUI
import SampleUI
import Combine

@main
struct SampleApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  
  @State private var responseText = ""
  private var cancellables: Set<AnyCancellable> = []
  @StateObject private var viewModel = ViewModel()
  
  var body: some View {
    Button("테스트") {
      viewModel.fetchData()
    }
    .padding()
    
    Text(viewModel.responseText)
      .padding()
  }
  
}

class ViewModel: ObservableObject {
  @Published var responseText = ""
  private var cancellables: Set<AnyCancellable> = []
  
  func fetchData() {
    let provider = NetworkProvider<SampleAPI>()
    return provider.request(target: .search(keyword: "game", offset: 1, limit: 10))
      .receive(on: DispatchQueue.main) // UI 업데이트는 메인 큐에서 수행
      .map { data in
        return String(data: data, encoding: .utf8) ?? "--"
      }
      .replaceError(with: "Error occurred") // 오류 발생 시 대체 값 지정
      .assign(to: \.responseText, on: self) // 값을 @State 속성에 할당
      .store(in: &cancellables)
  }
}

