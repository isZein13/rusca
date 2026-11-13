import SwiftUI
import WidgetKit

private let appGroupId = "group.com.rusca.app"
private let accent = Color(red: 0.110, green: 0.098, blue: 0.086)
private let ink = Color(red: 0.110, green: 0.098, blue: 0.086)
private let muted = Color(red: 0.435, green: 0.404, blue: 0.361)
private let background = Color(red: 1.0, green: 0.988, blue: 0.973)

struct WordEntry: TimelineEntry {
    let date: Date
    let trPron: String
    let ru: String
    let tr: String
}

struct WordProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), trPron: "Privet", ru: "Привет", tr: "Merhaba")
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(load())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let entry = load()
        let next = Calendar.current.date(byAdding: .hour, value: 4, to: Date())
            ?? Date().addingTimeInterval(4 * 3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func load() -> WordEntry {
        let prefs = UserDefaults(suiteName: appGroupId)
        return WordEntry(
            date: Date(),
            trPron: prefs?.string(forKey: "trPron") ?? "Privet",
            ru: prefs?.string(forKey: "ru") ?? "Привет",
            tr: prefs?.string(forKey: "tr") ?? "Merhaba"
        )
    }
}

struct RuscaWidgetEntryView: View {
    var entry: WordEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let content = content(for: family)
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) {
                if family == .systemSmall || family == .systemMedium {
                    background
                } else {
                    Color.clear
                }
            }
        } else {
            content
        }
    }

    @ViewBuilder
    private func content(for family: WidgetFamily) -> some View {
        switch family {
        case .accessoryInline:
            Text("\(entry.trPron) · \(entry.tr)")
                .lineLimit(1)
        case .accessoryCircular:
            Text(entry.trPron)
                .font(.system(size: 12, weight: .bold))
                .minimumScaleFactor(0.35)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.trPron)
                    .font(.system(size: 18, weight: .bold))
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)
                Text(entry.ru)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                Text(entry.tr)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        default:
            let compact = family == .systemSmall
            VStack(spacing: compact ? 6 : 10) {
                Text(entry.trPron)
                    .font(.system(size: compact ? 28 : 40, weight: .heavy))
                    .foregroundColor(accent)
                    .minimumScaleFactor(0.45)
                    .lineLimit(2)
                Text(entry.ru)
                    .font(.system(size: compact ? 16 : 22, weight: .semibold))
                    .foregroundColor(ink)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
                Text(entry.tr)
                    .font(.system(size: compact ? 13 : 16))
                    .foregroundColor(muted)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .padding(compact ? 12 : 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct RuscaWidget: Widget {
    let kind: String = "RuscaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WordProvider()) { entry in
            RuscaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Rusça")
        .description("Kilit ekranında, saatin yanında yeni kelime")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryInline,
            .accessoryRectangular,
            .accessoryCircular,
        ])
    }
}

@main
struct RuscaWidgetBundle: WidgetBundle {
    var body: some Widget {
        RuscaWidget()
    }
}
