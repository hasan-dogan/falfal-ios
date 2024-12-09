import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
	@Published var keyboardHeight: CGFloat = 0

	private var cancellable: AnyCancellable?
	private let notificationCenter: NotificationCenter

	init(notificationCenter: NotificationCenter = .default) {
		self.notificationCenter = notificationCenter

		cancellable = Publishers.Merge(
			notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
				.compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
				.map { $0.height },
			notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
				.map { _ in CGFloat(0) }
		)
		.assign(to: \.keyboardHeight, on: self)
	}

	deinit {
		cancellable?.cancel()
	}
}
