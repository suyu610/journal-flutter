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
        let userDefaults = UserDefaults(suiteName: "group.com.uuorb.journal_v2")
        
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
        let dailyTarget = entry.budgetAmount / 30.0
        let todayPercent = dailyTarget > 0 ? (entry.todayExpense / dailyTarget) : 0
        let themeColor = getThemeColor(percent: todayPercent)
        
        // --- 核心修改：移除最外层的 ZStack，直接写内容，背景通过修饰符添加 ---
        VStack(alignment: .leading, spacing: 0) {
            
            // --- 顶部区域：标题 + 大数字 + 主进度条 ---
            VStack(alignment: .leading, spacing: 4) {
                // ... (这里的内容保持不变，代码省略以节省篇幅) ...
                // 1. 标题栏
                HStack {
                    Text("今日支出")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(min(todayPercent, 9.9) * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(todayPercent > 1.0 ? .red : .secondary)
                }
                
                // 2. 大数字
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("¥")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.bottom, 2)
                    Text(String(format: "%.1f", entry.todayExpense))
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                .padding(.vertical, 2)
                
                // 3. 主进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 14)
                        Capsule()
                            .fill(getGradient(percent: todayPercent))
                            .frame(width: max(12, min(CGFloat(todayPercent) * geo.size.width, geo.size.width)), height: 14)
                            .shadow(color: getShadowColor(percent: todayPercent).opacity(0.25), radius: 3, x: 0, y: 2)
                    }
                }
                .frame(height: 14)
            }
            
            Spacer()
            
            // --- 底部区域：周/月统计 ---
            VStack(spacing: 10) {
                let weekTarget = entry.budgetAmount / 4.0
                let monthTarget = entry.budgetAmount
                
                MiniProgressBar(
                    label: "本周",
                    percent: entry.weekExpense / (weekTarget > 0 ? weekTarget : 1.0)
                )
                MiniProgressBar(
                    label: "本月",
                    percent: entry.monthExpense / (monthTarget > 0 ? monthTarget : 1.0)
                )
            }
        }
        // --- 关键点 1：在这里设置铺满的背景 ---
        .containerBackground(for: .widget) {
            ZStack {
                // 1. 底色
                Color(UIColor.systemBackground)
                
                // 2. 光晕 (现在会铺满整个Widget)
                LinearGradient(
                    gradient: Gradient(colors: [themeColor.opacity(0.12), themeColor.opacity(0.02), Color.clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 3. 水印
                GeometryReader { geo in
                    Text("¥")
                        .font(.system(size: 140, weight: .black, design: .serif))
                        .foregroundColor(themeColor)
                        .opacity(0.05)
                        .position(x: geo.size.width * 0.9, y: geo.size.height * 0.4)
                        .rotationEffect(.degrees(-15))
                }
            }
        }
        .widgetURL(URL(string: "journal://widget_1"))
    }
    
    // --- 辅助逻辑 ---
    
    // 获取当前的主题色（用于背景光晕）
    func getThemeColor(percent: Double) -> Color {
        if percent > 1.0 { return .red }
        if percent > 0.8 { return .orange }
        if percent > 0.4 { return .blue }
        return .green // 消费低时显示清新的绿色
    }
    
    // 渐变进度条逻辑 (保持原样)
    func getGradient(percent: Double) -> LinearGradient {
        if percent > 1.0 {
            return LinearGradient(gradient: Gradient(colors: [Color.red, Color.purple]), startPoint: .leading, endPoint: .trailing)
        } else if percent > 0.8 {
            return LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing)
        } else if percent > 0.4 {
            return LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.4, green: 0.9, blue: 0.6), Color.green]), startPoint: .leading, endPoint: .trailing)
        }
    }
    
    func getShadowColor(percent: Double) -> Color {
        if percent > 1.0 { return .red }
        if percent > 0.8 { return .orange }
        if percent > 0.4 { return .blue }
        return .green
    }
}

// --- 迷你进度条组件 ---
struct MiniProgressBar: View {
    let label: String
    let percent: Double
    var themeColor: Color = .blue // 新增：可接收外部主题色，或者内部自己算
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(getMiniGradient(percent: percent))
                        .frame(width: min(CGFloat(percent) * geo.size.width, geo.size.width), height: 6)
                }
            }
            .frame(height: 6)
            
            Text("\(Int(min(percent, 9.9) * 100))%")
                .font(.system(size: 11, weight: .bold))
                // 让百分比文字颜色也稍微呼应一下状态
                .foregroundColor(percent > 1.0 ? .red : .secondary)
                .frame(width: 38, alignment: .trailing)
        }
    }
    
    func getMiniGradient(percent: Double) -> LinearGradient {
        let colors: [Color]
        if percent > 1.0 { colors = [.red, .purple] }
        else if percent > 0.8 { colors = [.orange, .red] }
        else if percent > 0.4 { colors = [.cyan, .blue] }
        else { colors = [.green, .mint] }
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
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
