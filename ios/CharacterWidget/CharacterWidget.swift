import SwiftUI
import WidgetKit
import UIKit
import AppIntents

private let appGroup = "group.com.example.domainExtention.shared"

struct CharacterEntry: TimelineEntry {
  let date: Date
  let characterId: String
}

struct CharacterProvider: TimelineProvider {
  func placeholder(in context: Context) -> CharacterEntry {
    CharacterEntry(date: .now, characterId: "sukuna")
  }

  func getSnapshot(in context: Context, completion: @escaping (CharacterEntry) -> Void) {
    completion(readEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CharacterEntry>) -> Void) {
    completion(Timeline(entries: [readEntry()], policy: .never))
  }

  private func readEntry() -> CharacterEntry {
    let id = UserDefaults(suiteName: appGroup)?.string(forKey: "characterId") ?? "sukuna"
    return CharacterEntry(date: .now, characterId: id)
  }
}

struct CharacterWidgetView: View {
  let entry: CharacterEntry

  var body: some View {
    HStack(spacing: 12) {
      icon
        .resizable()
        .scaledToFit()
        .frame(width: 48, height: 48)
        .foregroundStyle(.white.opacity(0.76))
      Text(entry.characterId == "gojo" ? "Годжо" : "Сукуна")
        .font(.headline)
        .foregroundStyle(.white.opacity(0.94))
      Spacer(minLength: 0)
    }
    .padding(14)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
    .widgetURL(URL(string: "domain-extention://assistant"))
  }

  private var icon: Image {
    if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup),
       let image = UIImage(contentsOfFile: container.appendingPathComponent("character_widget.png").path) {
      return Image(uiImage: image)
    }
    return Image(systemName: entry.characterId == "gojo" ? "hand.raised.fingers.spread" : "hands.sparkles")
  }
}

struct CharacterHomeWidget: Widget {
  let kind = "CharacterHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: CharacterProvider()) { entry in
      CharacterWidgetView(entry: entry)
    }
    .configurationDisplayName("Персонаж")
    .description("Быстрый переход к выбранному персонажу.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct CharacterWidgetBundle: WidgetBundle {
  var body: some Widget {
    CharacterHomeWidget()
    if #available(iOSApplicationExtension 18.0, *) {
      CharacterControlWidget()
    }
  }
}

@available(iOSApplicationExtension 18.0, *)
struct CharacterControlWidget: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "CharacterVoiceControl") {
      ControlWidgetButton(action: OpenCharacterIntent()) {
        Label("Открыть персонажа", systemImage: "mic.fill")
      }
    }
    .displayName("Микрофон")
    .description("Открывает выбранного персонажа в приложении.")
  }
}

@available(iOSApplicationExtension 18.0, *)
struct OpenCharacterIntent: AppIntent {
  static var title: LocalizedStringResource = "Открыть персонажа"

  func perform() async throws -> some IntentResult & OpensIntent {
    let url = URL(string: "domain-extention://assistant")!
    return .result(opensIntent: OpenURLIntent(url))
  }
}
