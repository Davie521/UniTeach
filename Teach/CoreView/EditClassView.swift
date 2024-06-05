//
//  EditClassView.swift
//  Teach
//
//  Created by Davie on 04/06/2024.
//

import SwiftUI

struct EditClassView: View {
    @Binding var baseClass: BaseClass
    @ObservedObject var settingsModel: SettingsModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newClassPrice: Double = 0.0
    private let priceOptions: [Double] = Array(stride(from: 0.0, through: 500.0, by: 10.0))

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Class Information")) {
                    TextField("Class Name", text: $baseClass.name)
                    TextEditor(text: $baseClass.description)
                        .frame(height: 150)
                }
                
                Section(header: Text("Price")) {
                    Picker("Class Price", selection: $newClassPrice) {
                        ForEach(priceOptions, id: \.self) { price in
                            Text("¥\(price, specifier: "%.2f")").tag(price)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .onAppear {
                        newClassPrice = baseClass.price
                    }
                    .onChange(of: newClassPrice) { newValue in
                        baseClass.price = newValue
                    }
                }
                
                Button("Save") {
                    Task {
                        await settingsModel.addClass(baseClass)
                        dismiss()
                    }
                }
                
                Button("Delete Class") {
                    Task {
                        await settingsModel.removeClass(baseClass)
                        dismiss()
                    }
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Edit Class")
        }
    }
}

struct EditClassView_Previews: PreviewProvider {
    static var previews: some View {
        EditClassView(baseClass: .constant(BaseClass(id: "1", name: "Math", description: "Mathematics", teacherId: "1", price: 100.0, rating: 4.5, reviews: [])), settingsModel: SettingsModel())
    }
}
