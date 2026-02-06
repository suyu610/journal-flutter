package com.uuorb.journal 

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.content.res.ColorStateList
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class ExpenseWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
// --- 这是一个万能读取函数，专门解决类型崩溃问题 ---
    private fun getSafeDouble(prefs: SharedPreferences, key: String, defaultVal: Double): Double {
        return try {
            // 1. 尝试作为 Float 读取 (最常见情况)
            prefs.getFloat(key, defaultVal.toFloat()).toDouble()
        } catch (e: ClassCastException) {
            try {
                // 2. 如果报错，说明可能是 Long (当 Flutter 传过来 0 或 100 这种整数时)
                prefs.getLong(key, defaultVal.toLong()).toDouble()
            } catch (e2: ClassCastException) {
                try {
                    // 3. 还报错？试试是不是 String
                    prefs.getString(key, defaultVal.toString())?.toDoubleOrNull() ?: defaultVal
                } catch (e3: Exception) {
                    // 4. 彻底没办法了，返回默认值
                    defaultVal
                }
            }
        }
    }
    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        // 1. 获取 Flutter 存的数据
        val widgetData = HomeWidgetPlugin.getData(context)
val today = getSafeDouble(widgetData, "today_expense", 0.0)
        val week = getSafeDouble(widgetData, "week_expense", 0.0)
        val month = getSafeDouble(widgetData, "month_expense", 0.0)
        val budget = getSafeDouble(widgetData, "budget_amount", 1.0)        // 2. 计算逻辑 (还原 Swift 逻辑)
        val dailyTarget = budget / 30.0
        val todayPercent = if (dailyTarget > 0) today / dailyTarget else 0.0
        
        val weekTarget = budget / 4.0
        val weekPercent = if (weekTarget > 0) week / weekTarget else 0.0
        
        val monthTarget = budget
        val monthPercent = if (monthTarget > 0) month / monthTarget else 0.0

        // 3. 构建视图
        val views = RemoteViews(context.packageName, R.layout.widget_expense)

        // 设置文字
        views.setTextViewText(R.id.tv_today_expense, String.format("%.1f", today))
        views.setTextViewText(R.id.tv_percent, "${(todayPercent * 100).toInt()}%")
        views.setTextViewText(R.id.tv_week_percent, "${(weekPercent * 100).toInt()}%")
        views.setTextViewText(R.id.tv_month_percent, "${(monthPercent * 100).toInt()}%")

        // 设置进度条 (Android ProgressBar 满级是 100 或 10000，这里假设 max=100)
        views.setProgressBar(R.id.pb_today, 100, (todayPercent * 100).toInt().coerceIn(0, 100), false)
        views.setProgressBar(R.id.pb_week, 100, (weekPercent * 100).toInt().coerceIn(0, 100), false)
        views.setProgressBar(R.id.pb_month, 100, (monthPercent * 100).toInt().coerceIn(0, 100), false)

        // 4. 动态颜色逻辑 (还原 getThemeColor)
        val themeColor = getThemeColor(todayPercent)
        
        // 改变进度条颜色 (API 21+)
        views.setInt(R.id.pb_today, "setProgressTintList", themeColor)
        views.setTextColor(R.id.tv_percent, if (todayPercent > 1.0) Color.RED else Color.GRAY)
        
        // 改变背景光晕 (这里简单处理为改变背景色或透明度，复杂光晕需要不同的 drawable 资源)
        // 简单做法：改变背景 Tint
        // views.setInt(R.id.root_layout, "setBackgroundTintList", themeColor) 

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun getThemeColor(percent: Double): Int {
        return when {
            percent > 1.0 -> Color.RED
            percent > 0.8 -> Color.parseColor("#FFA500") // Orange
            percent > 0.4 -> Color.BLUE
            else -> Color.parseColor("#4CAF50") // Green
        }
    }
}