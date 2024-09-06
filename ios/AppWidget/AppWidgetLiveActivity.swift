//
//  AppWidgetLiveActivity.swift
//  AppWidget
//
//  Created by Sam Skulsky on 3/24/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AppWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AppWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AppWidgetAttributes {
    fileprivate static var preview: AppWidgetAttributes {
        AppWidgetAttributes(name: "World")
    }
}

extension AppWidgetAttributes.ContentState {
    fileprivate static var smiley: AppWidgetAttributes.ContentState {
        AppWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AppWidgetAttributes.ContentState {
         AppWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AppWidgetAttributes.preview) {
   AppWidgetLiveActivity()
} contentStates: {
    AppWidgetAttributes.ContentState.smiley
    AppWidgetAttributes.ContentState.starEyes
}
