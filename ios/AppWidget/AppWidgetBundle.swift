//
//  AppWidgetBundle.swift
//  AppWidget
//
//  Created by Sam Skulsky on 3/24/24.
//

import WidgetKit
import SwiftUI

@main
struct AppWidgetBundle: WidgetBundle {
    var body: some Widget {
        AppWidget()
        AppWidgetLiveActivity()
    }
}
