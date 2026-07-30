import SwiftUI

struct BreachListView: View {
    @Bindable var store: BreachStore
    @Binding var showSettings: Bool
    @State private var query = ""
    @State private var category: Breach.Category?
    @State private var path = NavigationPath()

    private var filtered: [Breach] {
        store.breaches.filter { breach in
            let matchesCategory = category == nil || breach.category == category
            let matchesQuery: Bool = {
                guard !query.isEmpty else { return true }
                let q = query.lowercased()
                return breach.company.lowercased().contains(q)
                    || breach.title.lowercased().contains(q)
                    || breach.summary.lowercased().contains(q)
            }()
            return matchesCategory && matchesQuery
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    header
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    ForEach(filtered) { breach in
                        Button {
                            path.append(breach.id)
                        } label: {
                            BreachRowView(breach: breach, status: store.status(for: breach.id))
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(category == nil ? "Open & recent" : category!.label)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settlements")
            .searchable(text: $query, prompt: "Company or settlement")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: String.self) { id in
                if let breach = store.breach(id: id) {
                    BreachDetailView(store: store, breach: breach)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Track real settlement windows — deadlines, estimated awards, and claim status in one place.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("All", selected: category == nil) { category = nil }
                    ForEach(Breach.Category.allCases, id: \.self) { item in
                        filterChip(item.label, selected: category == item) {
                            category = item
                        }
                    }
                }
            }
        }
    }

    private func filterChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .background(selected ? Theme.accent : Color(.tertiarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
