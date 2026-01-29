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
        // 1. 计算今日预算目标
        // 如果是月度预算模式，除以30天作为日预算；如果是总预算模式，这里暂时按月/30估算，你可以根据业务逻辑修改
        let dailyTarget = entry.budgetAmount / 30.0
        let todayPercent = dailyTarget > 0 ? (entry.todayExpense / dailyTarget) : 0
        
        return VStack(alignment: .leading, spacing: 0) {
            
            // --- 第一部分：今日支出 (主角：带进度条的大数字) ---
            VStack(alignment: .leading, spacing: 6) {
                
                // 顶部标签栏：左边标题，右边百分比
                HStack {
                    Text("今日支出")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 今日的百分比显示在这里
                    Text("\(Int(min(todayPercent, 9.9) * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(todayPercent > 1.0 ? .red : .primary)
                }
                
                // 核心数字
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("¥")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(String(format: "%.1f", entry.todayExpense))
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                
                // 今日专属进度条 (比较粗，更显眼)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 10) // 比如下面周月的 6px 更粗
                        
                        Capsule()
                            .fill(todayPercent > 1.0 ? Color.red : Color.blue) // 也是蓝色，但超支变红
                            .frame(width: min(CGFloat(todayPercent) * geo.size.width, geo.size.width), height: 10)
                    }
                }
                .frame(height: 10)
            }
            
            Spacer() // 撑开中间空隙
            
            // --- 第二部分：周与月 (配角：迷你进度条) ---
            VStack(spacing: 8) {
                // 计算辅助目标
                let weekTarget = entry.budgetAmount / 4.0
                let monthTarget = entry.budgetAmount
                
                // 复用之前的迷你组件，视觉上更细、更低调
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
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { Color(UIColor.systemBackground) }
    }
}

// --- 提取出的迷你进度条组件 ---
// 专门用于只展示进度，不展示金额的场景
struct MiniProgressBar: View {
    let label: String
    let percent: Double
    
    var body: some View {
        HStack(spacing: 8) {
            // 左侧：标签
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 48, alignment: .leading) // 固定宽度对齐
            
            // 中间：进度槽
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 灰色底槽
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 6)
                    
                    // 彩色进度
                    Capsule()
                        .fill(progressColor)
                        .frame(width: min(CGFloat(percent) * geo.size.width, geo.size.width), height: 6)
                }
            }
            .frame(height: 6) // 限制高度
            
            // 右侧：百分比
            Text("\(Int(min(percent, 9.9) * 100))%")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(percent > 1.0 ? .red : .secondary) // 超支变红
                .frame(width: 38, alignment: .trailing) // 固定宽度对齐
        }
    }
    
    // 根据进度决定颜色：正常是蓝色，稍微多了是橙色，超支是红色
    var progressColor: Color {
        if percent > 1.0 { return .red }
        if percent > 0.8 { return .orange }
        return .blue
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