import SwiftUI

struct CustomSettlementSheet: View {
    @Bindable var store: BreachStore
    var onCreated: (Breach) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var company = ""
    @State private var title = ""
    @State private var amountText = ""
    @State private var deadline = Calendar.current.date(byAdding: .month, value: 3, to: .now) ?? .now
    @State private var requiresProof = false
    @State private var category: Breach.Category = .consumer

    private var canSave: Bool {
        !company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (Double(amountText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Company", text: $company)
                    TextField("Settlement title", text: $title)
                    TextField("Estimated award (USD)", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Picker("Category", selection: $category) {
                        ForEach(Breach.Category.allCases, id: \.self) { item in
                            Text(item.label).tag(item)
                        }
                    }
                    Toggle("Proof may help", isOn: $requiresProof)
                } footer: {
                    Text("Custom settlements stay on this device. Always verify eligibility on the official claim site.")
                }
            }
            .navigationTitle("Add settlement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let amount = Double(amountText) ?? 0
                        let breach = store.addCustomBreach(
                            company: company,
                            title: title,
                            estimatedPayout: amount,
                            deadline: deadline,
                            requiresProof: requiresProof,
                            category: category
                        )
                        Haptics.success()
                        onCreated(breach)
                        dismiss()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
