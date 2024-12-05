import SwiftUI

struct FortuneCardView<Destination: View>: View {
	var title: String
	var info: String
	var redirectView: Destination

	var body: some View {
		NavigationLink(destination: redirectView) {
			HStack(spacing: 16) {
				Image("bg3")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 109, height: 109) // Sabit bir boyut
					.mask(RoundedRectangle(cornerRadius: 26, style: .continuous))
				VStack(spacing: 4) {
					Text(title)
						.font(.callout)
						.fontWeight(.semibold)
						.foregroundStyle(LinearGradient(
							colors: [.blue, .purple],
							startPoint: .leading,
							endPoint: .trailing
						))
						.frame(maxWidth: .infinity, alignment: .leading)

					Text(info)
						.font(.footnote)
						.foregroundStyle(.white)
						.lineLimit(2)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.frame(height: 109) // Sabit yükseklik
			}
			.padding()
			.frame(maxWidth: .infinity) // Tam genişlikte hizalama
			.background {
				RoundedRectangle(cornerRadius: 20, style: .continuous)
					.fill(Color(.secondarySystemBackground))
					.shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
			}
			.padding(.horizontal)
		}
		.buttonStyle(PlainButtonStyle()) // Tıklanabilir ancak varsayılan buton görünümü olmadan
	}
}
