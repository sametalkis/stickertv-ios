import Foundation

/// Universal sorting options for emote search across different providers.
public enum EmoteSortOption: String, CaseIterable, Identifiable, Codable, Sendable {
    case trendingDaily = "trending_daily"
    case trendingWeekly = "trending_weekly"
    case trendingMonthly = "trending_monthly"
    case topDaily = "top_daily"
    case topWeekly = "top_weekly"
    case topMonthly = "top_monthly"
    case topAllTime = "top_all_time"
    case nameAlphabetical = "name_alphabetical"
    case newest = "newest"
    
    public var id: String { rawValue }
    
    public var localizedTitle: String {
        switch self {
        case .trendingDaily: return "Günün Trendleri"
        case .trendingWeekly: return "Haftanın Trendleri"
        case .trendingMonthly: return "Ayın Trendleri"
        case .topDaily: return "Bugün En İyiler"
        case .topWeekly: return "Bu Hafta En İyiler"
        case .topMonthly: return "Bu Ay En İyiler"
        case .topAllTime: return "Tüm Zamanlar"
        case .nameAlphabetical: return "Alfabetik (A-Z)"
        case .newest: return "En Yeniler"
        }
    }
}
