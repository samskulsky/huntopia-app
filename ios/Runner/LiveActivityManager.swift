import ActivityKit
import Flutter
import Foundation

class LiveActivityManager {
    
    private var inGameWidgetActivity: Activity<InGameWidgetAttributes>? = nil

    private func parseDate(from string: String?) -> Date {
        guard let dateString = string else { return Date() }
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: dateString) ?? Date()
    }

    func startLiveActivity(data: [String: Any]?, result: @escaping FlutterResult) {
        guard let info = data else {
            result(FlutterError(code: "418", message: "No data provided for live activity", details: nil))
            return
        }

        let state = InGameWidgetAttributes.ContentState(
            gameId: info["gameId"] as? String ?? "",
            gameName: info["gameName"] as? String ?? "",
            hostName: info["hostName"] as? String ?? "",
            startTime: parseDate(from: info["startTime"] as? String),
            endTime: parseDate(from: info["endTime"] as? String),
            gameStatus: info["gameStatus"] as? String ?? "",
            playerCount: info["playerCount"] as? Int ?? 0,
            maxPlayers: info["maxTeams"] as? Int ?? 0,
            durationMinutes: info["durationMinutes"] as? Int ?? 0,
            timeLeftMinutes: info["timeLeftMinutes"] as? Int ?? 0,
            teamPlace: info["teamPlace"] as? Int ?? 0,
            teamScore: info["teamScore"] as? Int ?? 0,
            teamCoins: info["teamCoins"] as? Int ?? 0,
            zonesClaimed: info["zonesClaimed"] as? Int ?? 0,
            teamColor: info["teamColor"] as? String ?? "",
            teamName:  info["teamName"] as? String ?? ""
        )

        stopLiveActivity(result:result)
        
        Task {
            do {
                let activity = try await Activity<InGameWidgetAttributes>.request(attributes: InGameWidgetAttributes(), contentState: state, pushType: nil)
                self.inGameWidgetActivity = activity
                result("Live activity started")
            } catch {
                result(FlutterError(code: "418", message: "Failed to start live activity", details: error.localizedDescription))
            }
        }
    }

    func updateLiveActivity(data: [String: Any]?, result: @escaping FlutterResult) {
        guard let info = data else {
            result(FlutterError(code: "418", message: "No data provided for live activity update", details: nil))
            return
        }

        let updatedState = InGameWidgetAttributes.ContentState(
            gameId: info["gameId"] as? String ?? "",
            gameName: info["gameName"] as? String ?? "",
            hostName: info["hostName"] as? String ?? "",
            startTime: parseDate(from: info["startTime"] as? String),
            endTime: parseDate(from: info["endTime"] as? String),
            gameStatus: info["gameStatus"] as? String ?? "",
            playerCount: info["playerCount"] as? Int ?? 0,
            maxPlayers: info["maxTeams"] as? Int ?? 0,
            durationMinutes: info["durationMinutes"] as? Int ?? 0,
            timeLeftMinutes: info["timeLeftMinutes"] as? Int ?? 0,
            teamPlace: info["teamPlace"] as? Int ?? 0,
            teamScore: info["teamScore"] as? Int ?? 0,
            teamCoins: info["teamCoins"] as? Int ?? 0,
            zonesClaimed: info["zonesClaimed"] as? Int ?? 0,
            teamColor: info["teamColor"] as? String ?? "",
            teamName:  info["teamName"] as? String ?? ""
        )

        Task {
            await inGameWidgetActivity?.update(using: updatedState)
            result("Live activity updated")
        }
    }
    
    func stopLiveActivity(result: @escaping FlutterResult) {
        Task {
            await inGameWidgetActivity?.end(dismissalPolicy: .immediate)
            inGameWidgetActivity = nil
            result("Live activity stopped")
        }
    }
}
