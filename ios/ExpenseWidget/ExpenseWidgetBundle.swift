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
        // 这里列出你所有的组件
        ExpenseStatusWidget() // 修改后的普通组件名
        ExpenseWidgetLiveActivity() // 你的灵动岛组件
        ExpenseWidgetControl() // 你的控制中心组件
    }
}