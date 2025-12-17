import SwiftUI
import WidgetKit

struct AcmeWidgetEntry: TimelineEntry {
    let date: Date
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AcmeWidgetEntry {
        AcmeWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (AcmeWidgetEntry) -> Void) {
        completion(AcmeWidgetEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AcmeWidgetEntry>) -> Void) {
        let entry = AcmeWidgetEntry(date: Date())
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}

struct AcmeWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("AcmeWidget")
            .padding()
    }
}

@main
struct AcmeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AcmeWidget", provider: Provider()) { entry in
            AcmeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Acme Widget")
        .description("Example widget extension.")
    }
}

