import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var birthDate = Date()
    @State private var showDatePicker = false
    @EnvironmentObject var appState: AppState // AppState erişimi
	@State private var isLocked: Bool = false

    func logout(){
        Keychain.delete(key: "authToken")
        appState.isAuthenticated = false
		isLocked = false;
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Kişisel Bilgiler")) {
                    TextField("Ad", text: $viewModel.profile.name)
                    TextField("Soyad", text: $viewModel.profile.lastName)
                    TextField("Email", text: .constant(viewModel.profile.email))
                        .disabled(true)
                        
                    VStack(alignment: .leading) {
                        Text("Doğum Tarihi")
                        HStack {
                            Text(viewModel.profile.birthDate ?? "Tarih Seçilmedi")
                                .foregroundColor(viewModel.profile.birthDate == nil ? .gray : .primary)
                            
                            Spacer()
                            
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                Image(systemName: "calendar")
                            }
                        }
                        if showDatePicker {
                            DatePicker("Doğum Tarihi", selection: $birthDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .onChange(of: birthDate) { newValue in
                                    // Format the date as needed by your backend
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    viewModel.profile.birthDate = formatter.string(from: newValue)
                                    showDatePicker = false
                                }
                        }
                    }
                }

                Section(header: Text("Durum")) {
                    Picker("Medeni Durum", selection: $viewModel.profile.relationShip) {
                        ForEach(RelationShipEnum.allCases, id: \.self) { option in
                            Text(option.label).tag(option as RelationShipEnum?)
                        }
                    }

                    Picker("Cinsiyet", selection: $viewModel.profile.gender) {
                        ForEach(GenderEnum.allCases, id: \.self) { option in
                            Text(option.label).tag(option as GenderEnum?)
                        }
                    }

                    Picker("Çocuk Sahibi", selection: $viewModel.profile.hasChildren) {
                        ForEach(HasChildrenEnum.allCases, id: \.self) { option in
                            Text(option.label).tag(option as HasChildrenEnum?)
                        }
                    }
                }

                Section(header: Text("İş ve Eğitim")) {
                    Picker("İş Durumu", selection: $viewModel.profile.jobStatus) {
                        ForEach(JobStatusEnum.allCases, id: \.self) { option in
                            Text(option.label).tag(option as JobStatusEnum?)
                        }
                    }

                    Picker("Eğitim Seviyesi", selection: $viewModel.profile.educationLevel) {
                        ForEach(EducationLevelEnum.allCases, id: \.self) { option in
                            Text(option.label).tag(option as EducationLevelEnum?)
                        }
                    }
                }
            }
            .navigationTitle("Profil")
            .toolbar {
                Button("Kaydet") {
                    UIApplication.shared.dismissKeyboard() // Klavyeyi kapat
                    viewModel.updateProfile()
                }
                Button("Çıkış yap") {
                    logout()
                }
            }
            .onAppear {
                viewModel.fetchProfile()
                
                // If birthDate exists, convert string to Date
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
                .first(where: \.isKeyWindow) else { return }
        window.endEditing(true)
    }
}
