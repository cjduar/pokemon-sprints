//
//  SprintView.swift
//  Pokemon
//
//  Created by Christopher Duarte on 5/20/26.
//

import SwiftUI

struct SprintView: View {
    @EnvironmentObject var sprintManager: SprintManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var isShowingAddSprint = false

    var body: some View {
        NavigationView {
            ZStack {
                PokemonTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        activeSprintSection
                        rosterSection
                        yearEndBattleLink
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Sprints")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddSprint = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSprint) {
                AddSprintView()
                    .environmentObject(sprintManager)
                    .environmentObject(favoritesManager)
            }
        }
    }

    private var activeSprintSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Sprints")
                .font(.headline)

            if sprintManager.activeSprints.isEmpty {
                EmptySprintStateView()
            } else {
                ForEach(sprintManager.activeSprints) { sprint in
                    SprintCard(sprint: sprint)
                }
            }
        }
    }

    private var rosterSection: some View {
        VStack(spacing: 12) {
            SprintRosterView(
                title: "Sprint Team",
                subtitle: "Pokemon that evolved after every goal was met.",
                pokemon: sprintManager.sprintTeamPokemon,
                tint: Color.green
            )

            SprintRosterView(
                title: "Villainous Team",
                subtitle: "Pokemon claimed by missed sprint goals.",
                pokemon: sprintManager.villainousTeamPokemon,
                tint: Color.purple
            )
        }
    }

    private var yearEndBattleLink: some View {
        NavigationLink {
            YearEndBattleDetailView(
                sprintTeamPokemon: sprintManager.sprintTeamPokemon,
                villainousTeamPokemon: sprintManager.villainousTeamPokemon
            )
        } label: {
            YearEndBattleSummaryView(
                sprintTeamPokemon: sprintManager.sprintTeamPokemon,
                villainousTeamPokemon: sprintManager.villainousTeamPokemon
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SprintCard: View {
    @EnvironmentObject var sprintManager: SprintManager
    @State private var isFinishing = false
    @State private var evolutionError: String?
    let sprint: Sprint

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                SprintPokemonAvatar(pokemon: sprint.pokemon, size: 68)

                VStack(alignment: .leading, spacing: 4) {
                    Text(sprint.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(sprint.pokemon.name.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(dateRangeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(sprint.goalsMetCount)/\(sprint.goals.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }

            ProgressView(value: sprint.progress)
                .tint(PokemonTheme.accent)

            VStack(spacing: 8) {
                ForEach(sprint.goals) { goal in
                    Button {
                        sprintManager.toggleGoal(goal.id, in: sprint.id)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: goal.isMet ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(goal.isMet ? Color.green : Color.secondary)

                            Text(goal.title)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .strikethrough(goal.isMet)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            if let evolutionError {
                Text(evolutionError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    await finishSprint()
                }
            } label: {
                HStack {
                    if isFinishing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: sprint.allGoalsMet ? "sparkles" : "bolt.shield.fill")
                    }

                    Text(buttonTitle)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .foregroundStyle(.white)
                .background(sprint.allGoalsMet ? Color.green : Color.purple)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isFinishing)
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private var buttonTitle: String {
        if isFinishing {
            return sprint.allGoalsMet ? "Finding Evolution" : "Closing Sprint"
        }

        return sprint.allGoalsMet ? "Complete Sprint and Evolve" : "Close Sprint to Villainous Team"
    }

    private var dateRangeText: String {
        "\(sprint.startDate.formatted(date: .abbreviated, time: .omitted)) - \(sprint.endDate.formatted(date: .abbreviated, time: .omitted)) · \(sprint.durationWeeks) weeks"
    }

    private func finishSprint() async {
        guard !isFinishing else { return }

        isFinishing = true
        evolutionError = nil
        defer { isFinishing = false }

        if sprint.allGoalsMet {
            do {
                let evolvedPokemon = try await getEvolvedSprintPokemon(
                    for: sprint.pokemon.name,
                    currentLevel: sprint.pokemon.level
                )
                sprintManager.finishSprint(sprint.id, evolvedPokemon: evolvedPokemon)
            } catch {
                evolutionError = "Could not load evolution. Try again."
            }
        } else {
            sprintManager.finishSprint(sprint.id)
        }
    }
}

private struct YearEndBattleSummaryView: View {
    let sprintTeamPokemon: [SprintPokemon]
    let villainousTeamPokemon: [SprintPokemon]

    private var sprintPower: Int {
        sprintTeamPokemon.count
    }

    private var villainPower: Int {
        villainousTeamPokemon.count
    }

    private var leaderText: String {
        if sprintPower == villainPower {
            return "Year-end battle is tied"
        }

        return sprintPower > villainPower ? "Sprint Team is ahead" : "Villainous Team is ahead"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Year-End Battle")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(leaderText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                BattlePowerTile(title: "Sprint", value: sprintPower, tint: .green)
                BattlePowerTile(title: "Villainous", value: villainPower, tint: .purple)
            }
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

private struct YearEndBattleDetailView: View {
    let sprintTeamPokemon: [SprintPokemon]
    let villainousTeamPokemon: [SprintPokemon]

    private var sprintPower: Int {
        sprintTeamPokemon.count
    }

    private var villainPower: Int {
        villainousTeamPokemon.count
    }

    private var resultText: String {
        if sprintPower == villainPower {
            return "The battle is even. Every remaining sprint can decide the year."
        }

        return sprintPower > villainPower
            ? "Sprint Team is winning the year-end battle."
            : "Villainous Team is winning the year-end battle."
    }

    var body: some View {
        ZStack {
            PokemonTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(resultText)
                            .font(.title3)
                            .fontWeight(.bold)

                        HStack(spacing: 12) {
                            BattlePowerTile(title: "Sprint", value: sprintPower, tint: .green)
                            BattlePowerTile(title: "Villainous", value: villainPower, tint: .purple)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground).opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    SprintRosterView(
                        title: "Sprint Team",
                        subtitle: "Your evolved Pokemon roster.",
                        pokemon: sprintTeamPokemon,
                        tint: .green
                    )

                    SprintRosterView(
                        title: "Villainous Team",
                        subtitle: "Pokemon lost to missed sprint goals.",
                        pokemon: villainousTeamPokemon,
                        tint: .purple
                    )
                }
                .padding(16)
            }
        }
        .navigationTitle("Year-End Battle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BattlePowerTile: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct SprintRosterView: View {
    let title: String
    let subtitle: String
    let pokemon: [SprintPokemon]
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(pokemon.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(tint)
                    .clipShape(Capsule())
            }

            if pokemon.isEmpty {
                Text("No Pokemon yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(pokemon) { pokemon in
                            VStack(spacing: 6) {
                                SprintPokemonAvatar(pokemon: pokemon, size: 58)

                                Text(pokemon.name.capitalized)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)

                            }
                            .frame(width: 82)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

private struct EmptySprintStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "flag.checkered.circle")
                .font(.system(size: 48))
                .foregroundStyle(PokemonTheme.accent)

            Text("Create a sprint to assign a Pokemon and track goals.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(Color(.systemBackground).opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct SprintPokemonAvatar: View {
    let pokemon: SprintPokemon
    let size: CGFloat

    var body: some View {
        AsyncImage(url: pokemon.artworkURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
                .controlSize(.small)
        }
        .frame(width: size, height: size)
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct AddSprintView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sprintManager: SprintManager
    @EnvironmentObject var favoritesManager: FavoritesManager

    @State private var title = ""
    @State private var selectedPokemon: Pokemon?
    @State private var startDate = Date()
    @State private var durationWeeks = 2
    @State private var goals = [""]

    init(preselectedPokemon: Pokemon? = nil) {
        _selectedPokemon = State(initialValue: preselectedPokemon)
    }

    private let durationOptions = [1, 2, 3, 4, 6, 8]

    private var canCreateSprint: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedPokemon != nil &&
        !goalTitles.isEmpty
    }

    private var goalTitles: [String] {
        goals
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var endDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate) ?? startDate
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Sprint") {
                    TextField("Sprint name", text: $title)

                    DatePicker("Start date", selection: $startDate, displayedComponents: .date)

                    Picker("Duration", selection: $durationWeeks) {
                        ForEach(durationOptions, id: \.self) { weeks in
                            Text("\(weeks) weeks")
                                .tag(weeks)
                        }
                    }

                    HStack {
                        Text("End date")

                        Spacer()

                        Text(endDate.formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Pokemon") {
                    NavigationLink {
                        SprintPokemonPickerView(selectedPokemon: $selectedPokemon)
                            .environmentObject(favoritesManager)
                    } label: {
                        HStack {
                            Text("Assigned Pokemon")

                            Spacer()

                            if let selectedPokemon {
                                Text(selectedPokemon.name.capitalized)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Choose")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Goals") {
                    ForEach(goals.indices, id: \.self) { index in
                        HStack {
                            TextField("Goal \(index + 1)", text: $goals[index])

                            if goals.count > 1 {
                                Button {
                                    goals.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        goals.append("")
                    } label: {
                        Label("Add Goal", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("New Sprint")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createSprint()
                    }
                    .disabled(!canCreateSprint)
                }
            }
        }
    }

    private func createSprint() {
        guard let selectedPokemon else { return }

        sprintManager.addSprint(
            title: title,
            pokemon: SprintPokemon(
                name: selectedPokemon.name,
                artworkURL: selectedPokemon.artworkURL,
                level: 1
            ),
            goals: goalTitles,
            startDate: startDate,
            durationWeeks: durationWeeks
        )
        dismiss()
    }
}

private struct SprintPokemonPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var pokemonViewModel = PokemonViewModel()
    @Binding var selectedPokemon: Pokemon?
    @State private var selectedList = PokemonPickerList.all

    private var visiblePokemon: [Pokemon] {
        switch selectedList {
        case .all:
            return pokemonViewModel.pokemons
        case .favorites:
            return pokemonViewModel.pokemons.filter { favoritesManager.isFavorite($0.name) }
        }
    }

    var body: some View {
        ZStack {
            PokemonTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Picker("Pokemon source", selection: $selectedList) {
                    ForEach(PokemonPickerList.allCases) { list in
                        Text(list.title)
                            .tag(list)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top], 16)

                if pokemonViewModel.pokemons.isEmpty {
                    Spacer()
                    ProgressView("Loading Pokemon")
                    Spacer()
                } else if visiblePokemon.isEmpty {
                    Spacer()
                    Text("No favorite Pokemon yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(visiblePokemon) { pokemon in
                                Button {
                                    selectedPokemon = pokemon
                                    dismiss()
                                } label: {
                                    PokemonRowView(
                                        pokemon: pokemon,
                                        isFavorite: favoritesManager.isFavorite(pokemon.name)
                                    )
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    if selectedList == .all && pokemon.id == pokemonViewModel.pokemons.last?.id {
                                        pokemonViewModel.loadMorePokemonIfNeeded()
                                    }
                                }
                            }

                            if pokemonViewModel.isLoading {
                                ProgressView()
                                    .padding(.vertical, 24)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .navigationTitle("Choose Pokemon")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if pokemonViewModel.pokemons.isEmpty {
                pokemonViewModel.fetchPokemons()
            }
        }
    }
}

private enum PokemonPickerList: String, CaseIterable, Identifiable {
    case all
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        }
    }
}

struct SprintView_Previews: PreviewProvider {
    static var previews: some View {
        SprintView()
            .environmentObject(SprintManager())
            .environmentObject(FavoritesManager())
    }
}
