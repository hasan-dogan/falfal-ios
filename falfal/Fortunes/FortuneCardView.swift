import SwiftUI

struct FortuneCardView<Destination: View>: View {
	var title: String
	var info: String
	var redirectView: Destination
	
	var body: some View {
		NavigationLink(destination: redirectView) {
			HStack(spacing: 16) {
				// Image with subtle overlay
				Image("bg3")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 109, height: 109)
					.clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
					.overlay(
						RoundedRectangle(cornerRadius: 26, style: .continuous)
							.stroke(.white.opacity(0.2), lineWidth: 0.5)
					)
				
				VStack(alignment: .leading, spacing: 8) {
					Text(title)
						.font(.system(size: 18, weight: .semibold))
						.foregroundStyle(LinearGradient(
							colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
							startPoint: .leading,
							endPoint: .trailing
						))
						.frame(maxWidth: .infinity, alignment: .leading)
					
					Text(info)
						.font(.system(size: 15))
						.foregroundColor(Color(.systemCyan))
						.lineLimit(2)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.frame(height: 109)
			}
			.padding(16)
			.frame(maxWidth: .infinity)
			.background {
				RoundedRectangle(cornerRadius: 20, style: .continuous)
					.fill(Color(.systemGray6))
					.overlay(
						RoundedRectangle(cornerRadius: 20, style: .continuous)
							.stroke(.white.opacity(0.1), lineWidth: 0.5)
					)
			}
			.shadow(color: Color.purple.opacity(0.2), radius: 10, x: 0, y: 5)
			.padding(.horizontal)
		}
		.buttonStyle(PlainButtonStyle())
	}
}
