import WidgetKit
import SwiftUI

// --- 数据模型 ---
enum BudgetType: String, Codable {
    case total
    case month
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let budgetType: BudgetType
    let todayExpense: Double
    let weekExpense: Double
    let monthExpense: Double
    let totalExpense: Double 
    let budgetAmount: Double        // 预算总额
}

// --- 数据提供者 ---
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), budgetType: .total, todayExpense: 0.0, weekExpense: 0.0, monthExpense: 0.0, totalExpense: 0.0, budgetAmount: 1000.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), budgetType: .total, todayExpense: 125.0, weekExpense: 850.0, monthExpense: 2100.0, totalExpense: 2100.0, budgetAmount: 5000.0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let userDefaults = UserDefaults(suiteName: "group.com.uuorb.susujournal")
        
        // 读取 Flutter 传过来的数据
        let typeString = userDefaults?.string(forKey: "budget_type") ?? "total"
        let budgetType = BudgetType(rawValue: typeString) ?? .total
        
        let today = userDefaults?.double(forKey: "today_expense") ?? 0.0
        let week = userDefaults?.double(forKey: "week_expense") ?? 0.0
        let month = userDefaults?.double(forKey: "month_expense") ?? 0.0
        let total = userDefaults?.double(forKey: "total_expense") ?? 0.0
        let budget = userDefaults?.double(forKey: "budget_amount") ?? 1.0 // 避免除以0
        
        let entry = SimpleEntry(
            date: Date(),
            budgetType: budgetType,
            todayExpense: today,
            weekExpense: week,
            monthExpense: month,
            totalExpense: total,
            budgetAmount: budget
        )

        // 15分钟刷新一次
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// --- 视图部分 ---
struct ExpenseWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.budgetType == .total {
                // 模式 A: 总预算 (今日/本周/总进度)
                statItem(title: "今日支出", amount: entry.todayExpense)
                statItem(title: "本周支出", amount: entry.weekExpense)
                progressSection(title: "预算进度", current: entry.totalExpense, target: entry.budgetAmount)
            } else {
                // 模式 B: 每月预算 (本日花销/本周进度/本月进度)
                progressSection(title: "本日花销", current: entry.todayExpense, target: (entry.budgetAmount / 30))
                progressSection(title: "本周花销", current: entry.weekExpense, target: entry.budgetAmount / 4)
                progressSection(title: "本月花销", current: entry.monthExpense, target: entry.budgetAmount)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { Color(UIColor.systemBackground) }
    }

    // 纯文字金额显示
    private func statItem(title: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.system(size: 10)).foregroundColor(.secondary)
            Text("¥\(String(format: "%.1f", amount))")
                .font(.system(size: 15, weight: .bold))
        }
    }

    // 进度条显示
    private func progressSection(title: String, current: Double, target: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title).font(.system(size: 10)).foregroundColor(.secondary)
                Spacer()
                Text("\(Int(min(current/target, 9.9) * 100))%").font(.system(size: 10))
            }
            ProgressView(value: min(current / target, 1.0))
                .tint(current > target ? .red : .blue)
                .scaleEffect(x: 1, y: 0.6, anchor: .center)
        }
    }
}

// --- 组件定义 ---
struct ExpenseStatusWidget: Widget {
    let kind: String = "ExpenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ExpenseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("消费统计")
        .description("实时查看预算支出进度")
        .supportedFamilies([.systemSmall])
    }
}