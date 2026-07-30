import SwiftUI

struct BreachListView: View {
    @Bindable var store: BreachStore
    @Bindable var entitlements: EntitlementStore
    @Binding var showSettings: Bool
    var onShowPaywall: (String) -> Void

    @State private var query = ""
    @State private var category: Breach.Category?
    @State private var path = NavigationPath()
    @State private var showCustom = false

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

                    CatalogHonestyBanner(
                        statusMessage: store.catalogStatusMessage,
                        syncedAt: store.catalogSyncedAt,
                        methodology: store.catalogMethodology
                    )
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    if filtered.isEmpty {
                        ContentUnavailableView.search(text: query.isEmpty ? "filters" : query)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filtered) { breach in
                            Button {
                                path.append(breach.id)
                            } label: {
                                BreachRowView(breach: breach, status: store.status(for: breach.id))
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Opens settlement details")
                        }
                    }
                } header: {
                    Text(category == nil ? "Open & recent" : category!.label)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settlements")
            .searchable(text: $query, prompt: "Company or settlement")
            .refreshable {
                await store.refreshCatalog()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if entitlements.unlocks(.customSettlements) {
                            showCustom = true
                        } else {
                            onShowPaywall("Add custom settlements with Breach Kit Pro.")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add custom settlement")
                }
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
                    BreachDetailView(
                        store: store,
                        entitlements: entitlements,
                        breach: breach,
                        onShowPaywall: onShowPaywall
                    )
                }
            }
            .sheet(isPresented: $showCustom) {
                CustomSettlementSheet(store: store) { breach in
                    path.append(breach.id)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Organize open claim windows — deadlines, checklists, and status. Free to watch; Pro adds smarter reminders.")
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
            .accessibilityElement(children: .contain)
        }
    }

    private func filterChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.light()
            action()
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .background(selected ? Theme.accent : Color(.tertiarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityLabel("\(title) category filter")
    }
}
