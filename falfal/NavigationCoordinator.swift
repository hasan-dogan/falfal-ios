import SwiftUI

class NavigationCoordinator: ObservableObject {
	@Published var currentTab: Int = 0
	@Published var isShowingTarotCardSelection = false
	@Published var selectedQuestion: String = ""
	
	static let shared = NavigationCoordinator()
	
	private init() {}
	
	func navigateToTarotCardSelection(with adManager: AdManager, question: String) {
		selectedQuestion = question
		isShowingTarotCardSelection = true
	}
}

struct RootNavigationView: View {
	@StateObject private var coordinator = NavigationCoordinator.shared
	var adManager: AdManager
	
	var body: some View {
		NavigationStack {
			TabBarView(adManager: adManager)
				.navigationDestination(isPresented: $coordinator.isShowingTarotCardSelection) {
					TarotCardSelectionView(
						adManager: adManager,
						question: coordinator.selectedQuestion
					)
				}
		}
	}
}
