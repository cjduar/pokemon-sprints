////
////  PokemonDetailView.swift
////  Pokemon
////
////  Created by Christopher Duarte on 1/28/24.

import SwiftUI

struct PokemonView: View {
    @State private var pkmon: PokemonData?
    @State private var selectedSpriteTitle = "Front"
    @State private var loadingError: String?
    @EnvironmentObject var favoritesManager: FavoritesManager

    var pokemonName: String

    private var displayName: String {
        pkmon?.species.name.capitalized ?? pokemonName.capitalized
    }

    private var selectedSpriteURL: URL? {
        spriteOptions.first(where: { $0.title == selectedSpriteTitle })?.url ?? spriteOptions.first?.url
    }

    private var spriteOptions: [SpriteOption] {
        guard let sprites = pkmon?.sprites else {
            return [
                SpriteOption(title: "Front", url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"))
            ]
        }

        return [
            SpriteOption(title: "Front", url: sprites.frontDefault),
            SpriteOption(title: "Back", url: sprites.backDefault),
            SpriteOption(title: "Shiny", url: sprites.frontShiny),
            SpriteOption(title: "Back shiny", url: sprites.backShiny)
        ].filter { $0.url != nil }
    }

    private var primaryTypeName: String {
        pkmon?.types.sorted { $0.slot < $1.slot }.first?.type.name ?? "normal"
    }

    private var typeColor: Color {
        PokemonTypeColor.color(for: primaryTypeName)
    }

    private var isFavorite: Bool {
        favoritesManager.isFavorite(pokemonName)
    }

    var body: some View {
        ZStack {
            PokemonTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    heroSection

                    if let loadingError {
                        Text(loadingError)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    infoSection
                    spriteSection
                    statsSection
                    favoriteButton
                }
                .padding(16)
            }
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPokemon()
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(typeColor.opacity(0.22))
                    .frame(width: 230, height: 230)

                Circle()
                    .stroke(typeColor.opacity(0.35), lineWidth: 2)
                    .frame(width: 230, height: 230)

                AsyncImage(url: selectedSpriteURL) { image in
                    image
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .controlSize(.large)
                }
                .frame(width: 190, height: 190)
            }

            VStack(spacing: 10) {
                Text(displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                typeChips
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 22)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var typeChips: some View {
        HStack(spacing: 8) {
            ForEach(pkmon?.types.sorted { $0.slot < $1.slot } ?? []) { pokemonType in
                Text(pokemonType.type.name.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .foregroundStyle(.white)
                    .background(PokemonTypeColor.color(for: pokemonType.type.name))
                    .clipShape(Capsule())
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                InfoTile(title: "Height", value: heightText)
                InfoTile(title: "Weight", value: weightText)
                InfoTile(title: "Base XP", value: baseExperienceText)
                InfoTile(title: "Type", value: primaryTypeName.capitalized)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var spriteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Sprite")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(spriteOptions) { sprite in
                    Button {
                        selectedSpriteTitle = sprite.title
                    } label: {
                        SpriteCard(
                            title: sprite.title,
                            imageURL: sprite.url,
                            isSelected: selectedSpriteTitle == sprite.title,
                            tint: typeColor
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Stats")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(pkmon?.stats ?? []) { stat in
                    StatRow(stat: stat, tint: typeColor)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var favoriteButton: some View {
        Button {
            favoritesManager.toggleFavorite(for: pokemonName)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.headline)

                Text(isFavorite ? "Remove Favorite" : "Add Favorite")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(isFavorite ? Color.orange : typeColor)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var heightText: String {
        guard let height = pkmon?.height else { return "--" }
        return String(format: "%.1f m", Double(height) / 10)
    }

    private var weightText: String {
        guard let weight = pkmon?.weight else { return "--" }
        return String(format: "%.1f kg", Double(weight) / 10)
    }

    private var baseExperienceText: String {
        guard let baseExperience = pkmon?.baseExperience else { return "--" }
        return "\(baseExperience)"
    }

    private func loadPokemon() async {
        do {
            loadingError = nil
            pkmon = try await getPokemon(pokemonName: pokemonName)
            selectedSpriteTitle = spriteOptions.first?.title ?? "Front"
        } catch {
            loadingError = "Unable to load this Pokemon right now."
        }
    }
}

private struct SpriteOption: Identifiable {
    let title: String
    let url: URL?

    var id: String { title }
}

private struct InfoTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct SpriteCard: View {
    let title: String
    let imageURL: URL?
    let isSelected: Bool
    let tint: Color

    var body: some View {
        VStack(spacing: 10) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
            } placeholder: {
                ProgressView()
                    .controlSize(.small)
            }
            .frame(width: 82, height: 82)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? tint : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isSelected ? tint : .clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct StatRow: View {
    let stat: PokemonData.Stat
    let tint: Color

    private var progress: Double {
        min(Double(stat.baseStat) / 160, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(stat.stat.name.replacingOccurrences(of: "-", with: " ").capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(stat.baseStat)")
                    .font(.caption)
                    .fontWeight(.bold)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.secondarySystemBackground))

                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
}

private enum PokemonTypeColor {
    static func color(for typeName: String) -> Color {
        switch typeName.lowercased() {
        case "fire": return Color(red: 0.93, green: 0.27, blue: 0.18)
        case "water": return Color(red: 0.18, green: 0.43, blue: 0.82)
        case "grass": return Color(red: 0.25, green: 0.65, blue: 0.34)
        case "electric": return Color(red: 0.91, green: 0.68, blue: 0.12)
        case "ice": return Color(red: 0.28, green: 0.72, blue: 0.78)
        case "fighting": return Color(red: 0.66, green: 0.20, blue: 0.16)
        case "poison": return Color(red: 0.55, green: 0.28, blue: 0.68)
        case "ground": return Color(red: 0.72, green: 0.52, blue: 0.22)
        case "flying": return Color(red: 0.45, green: 0.55, blue: 0.82)
        case "psychic": return Color(red: 0.86, green: 0.25, blue: 0.49)
        case "bug": return Color(red: 0.49, green: 0.62, blue: 0.18)
        case "rock": return Color(red: 0.55, green: 0.47, blue: 0.27)
        case "ghost": return Color(red: 0.34, green: 0.30, blue: 0.58)
        case "dragon": return Color(red: 0.38, green: 0.26, blue: 0.78)
        case "dark": return Color(red: 0.25, green: 0.22, blue: 0.20)
        case "steel": return Color(red: 0.45, green: 0.51, blue: 0.58)
        case "fairy": return Color(red: 0.86, green: 0.42, blue: 0.67)
        default: return Color(red: 0.46, green: 0.52, blue: 0.48)
        }
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PokemonView(pokemonName: "pikachu")
                .environmentObject(FavoritesManager())
        }
    }
}
