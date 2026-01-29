//
//  ExpenseWidgetBundle.swift
//  ExpenseWidget
//
//  Created by uuorb on 2026/1/29.
//

import WidgetKit
import SwiftUI

@main
struct ExpenseWidgetBundle: WidgetBundle {
    var body: some Widget {
        ExpenseWidget()
        ExpenseWidgetControl()
        ExpenseWidgetLiveActivity()
    }
}
