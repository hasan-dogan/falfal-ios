import SwiftUI

struct ProfileView: View {
	@StateObject private var viewModel = ProfileViewModel()
	@State private var birthDate = Date()
	@State private var showDatePicker = false
	@EnvironmentObject var appState: AppState
	@State private var isLocked: Bool = false
	@State private var showConfirmation: Bool = false
	@State private var redirectStatus: Bool = true
	
	
	
	func logout() {
		Keychain.delete(key: "authToken")
		appState.isAuthenticated = false
		isLocked = false

	}
	
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Kişisel Bilgiler").font(.headline).foregroundColor(.blue)) {
					VStack(alignment: .leading) {
						Text("Ad")
							.font(.subheadline)
							.foregroundColor(.secondary)
						TextField("Ad", text: $viewModel.profile.name)
							.padding(10)
							.background(Color.gray.opacity(0.1))
							.cornerRadius(8)
							.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
					}
					
					VStack(alignment: .leading) {
						Text("Soyad")
							.font(.subheadline)
							.foregroundColor(.secondary)
						TextField("Soyad", text: $viewModel.profile.lastName)
							.padding(10)
							.background(Color.gray.opacity(0.1))
							.cornerRadius(8)
							.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
					}
					
					TextField("Email", text: .constant(viewModel.profile.email))
						.disabled(true)
						.foregroundColor(.gray)
					
					VStack(alignment: .leading) {
						Text("Doğum Tarihi")
							.font(.subheadline)
							.foregroundColor(.secondary)
						
						HStack {
							Text(viewModel.profile.birthDate ?? "Tarih Seçilmedi")
								.foregroundColor(viewModel.profile.birthDate == nil ? .gray : .primary)
							Spacer()
							Button(action: {
								showDatePicker.toggle()
							}) {
								Image(systemName: "calendar")
									.foregroundColor(.blue)
							}
						}
						if showDatePicker {
							DatePicker("Doğum Tarihi", selection: $birthDate, displayedComponents: .date)
								.datePickerStyle(GraphicalDatePickerStyle())
								.onChange(of: birthDate) { newValue in
									let formatter = DateFormatter()
									formatter.dateFormat = "yyyy-MM-dd"
									viewModel.profile.birthDate = formatter.string(from: newValue)
									showDatePicker = false
								}
						}
					}
				}
				
				Section(header: Text("Durum").font(.headline).foregroundColor(.blue)) {
					Picker("Medeni Durum", selection: $viewModel.profile.relationShip) {
						ForEach(RelationShipEnum.allCases, id: \ .self) { option in
							Text(option.label).tag(option as RelationShipEnum?)
						}
					}
					
					Picker("Cinsiyet", selection: $viewModel.profile.gender) {
						ForEach(GenderEnum.allCases, id: \ .self) { option in
							Text(option.label).tag(option as GenderEnum?)
						}
					}
					
					Picker("Çocuk Sahibi", selection: $viewModel.profile.hasChildren) {
						ForEach(HasChildrenEnum.allCases, id: \ .self) { option in
							Text(option.label).tag(option as HasChildrenEnum?)
						}
					}
				}
				
				Section(header: Text("İş ve Eğitim").font(.headline).foregroundColor(.blue)) {
					Picker("İş Durumu", selection: $viewModel.profile.jobStatus) {
						ForEach(JobStatusEnum.allCases, id: \ .self) { option in
							Text(option.label).tag(option as JobStatusEnum?)
						}
					}
					
					Picker("Eğitim Seviyesi", selection: $viewModel.profile.educationLevel) {
						ForEach(EducationLevelEnum.allCases, id: \ .self) { option in
							Text(option.label).tag(option as EducationLevelEnum?)
						}
					}
				}
				
				Section {
					HStack {
						Spacer()
						Button(action: {
							UIApplication.shared.dismissKeyboard()
							viewModel.updateProfile()
							showConfirmation = true
							DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
								showConfirmation = false
							}
						}) {
							Text("Kaydet")
								.font(.headline)
								.padding()
								.frame(maxWidth: .infinity)
								.background(Color.green)
								.foregroundColor(.white)
								.cornerRadius(8)
						}
						Spacer()
					}
					
					HStack {
						Spacer()
						Button(action: {
							logout()
						}) {
							Text("Çıkış yap")
								.font(.headline)
								.padding()
								.frame(maxWidth: .infinity)
								.background(Color.red)
								.foregroundColor(.white)
								.cornerRadius(8)
						}
						Spacer()
					}
				}
			}
			.navigationTitle("Profil")
			.overlay(
				Group {
					if showConfirmation {
						HStack {
							Image(systemName: "checkmark.circle.fill")
								.foregroundColor(.green)
							Text("Kaydedildi")
								.foregroundColor(.green)
								.font(.headline)
						}
						.padding()
						.background(Color.white)
						.cornerRadius(8)
						.shadow(radius: 4)
						.transition(.opacity)
						.zIndex(1)
					}
				}
			)
			.onAppear {
				viewModel.fetchProfile()
				if let birthDateString = viewModel.profile.birthDate {
					let formatter = DateFormatter()
					formatter.dateFormat = "yyyy-MM-dd"
					if let date = formatter.date(from: birthDateString) {
						birthDate = date
					}
				}
			}
		}
	}
}

extension UIApplication {
	func dismissKeyboard() {
		guard let window = connectedScenes
			.compactMap({ $0 as? UIWindowScene })
			.first?.windows
			.first(where: \ .isKeyWindow) else { return }
		window.endEditing(true)
	}
}
