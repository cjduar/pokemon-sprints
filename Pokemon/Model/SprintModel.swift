//
//  SprintModel.swift
//  Pokemon
//
//  Created by Christopher Duarte on 5/20/26.
//

import Foundation

struct SprintPokemon: Codable, Equatable, Identifiable {
    let name: String
    let artworkURL: URL?
    var level: Int

    var id: String { name.lowercased() }
}

struct SprintGoal: Codable, Equatable, Identifiable {
    let id: UUID
    var title: String
    var isMet: Bool

    init(id: UUID = UUID(), title: String, isMet: Bool = false) {
        self.id = id
        self.title = title
        self.isMet = isMet
    }
}

enum SprintOutcome: String, Codable {
    case active
    case sprintTeam
    case villainousTeam

    var title: String {
        switch self {
        case .active: return "Active"
        case .sprintTeam: return "Sprint Team"
        case .villainousTeam: return "Villainous Team"
        }
    }
}

struct Sprint: Codable, Equatable, Identifiable {
    let id: UUID
    var title: String
    var pokemon: SprintPokemon
    var goals: [SprintGoal]
    var startDate: Date
    var durationWeeks: Int
    var outcome: SprintOutcome
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        pokemon: SprintPokemon,
        goals: [SprintGoal],
        startDate: Date,
        durationWeeks: Int,
        outcome: SprintOutcome = .active,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.pokemon = pokemon
        self.goals = goals
        self.startDate = startDate
        self.durationWeeks = durationWeeks
        self.outcome = outcome
        self.completedAt = completedAt
    }

    var goalsMetCount: Int {
        goals.filter(\.isMet).count
    }

    var progress: Double {
        guard !goals.isEmpty else { return 0 }
        return Double(goalsMetCount) / Double(goals.count)
    }

    var allGoalsMet: Bool {
        !goals.isEmpty && goals.allSatisfy(\.isMet)
    }

    var endDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate) ?? startDate
    }
}

final class SprintManager: ObservableObject {
    @Published private(set) var sprints: [Sprint] = []

    var activeSprints: [Sprint] {
        sprints.filter { $0.outcome == .active }
    }

    var sprintTeamPokemon: [SprintPokemon] {
        sprints
            .filter { $0.outcome == .sprintTeam }
            .map(\.pokemon)
    }

    var villainousTeamPokemon: [SprintPokemon] {
        sprints
            .filter { $0.outcome == .villainousTeam }
            .map(\.pokemon)
    }

    func addSprint(title: String, pokemon: SprintPokemon, goals: [String], startDate: Date, durationWeeks: Int) {
        let cleanGoals = goals
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { SprintGoal(title: $0) }

        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !cleanGoals.isEmpty else { return }

        let sprint = Sprint(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            pokemon: pokemon,
            goals: cleanGoals,
            startDate: startDate,
            durationWeeks: durationWeeks
        )

        sprints.insert(sprint, at: 0)
    }

    func toggleGoal(_ goalID: UUID, in sprintID: UUID) {
        guard let sprintIndex = sprints.firstIndex(where: { $0.id == sprintID }),
              let goalIndex = sprints[sprintIndex].goals.firstIndex(where: { $0.id == goalID }),
              sprints[sprintIndex].outcome == .active else { return }

        sprints[sprintIndex].goals[goalIndex].isMet.toggle()
    }

    func finishSprint(_ sprintID: UUID, evolvedPokemon: SprintPokemon? = nil) {
        guard let sprintIndex = sprints.firstIndex(where: { $0.id == sprintID }),
              sprints[sprintIndex].outcome == .active else { return }

        if sprints[sprintIndex].allGoalsMet {
            if let evolvedPokemon {
                sprints[sprintIndex].pokemon = evolvedPokemon
            }
            sprints[sprintIndex].outcome = .sprintTeam
        } else {
            sprints[sprintIndex].outcome = .villainousTeam
        }

        sprints[sprintIndex].completedAt = Date()
    }
}
