import ActivityKit
import WidgetKit
import SwiftUI

struct InGameWidgetAttributes: ActivityAttributes {
    public typealias GameStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var gameId: String
        var gameName: String
        var hostName: String
        var startTime: Date
        var endTime: Date
        var gameStatus: String
        var playerCount: Int
        var maxPlayers: Int
        var durationMinutes: Int
        var timeLeftMinutes: Int
        // Additional details for live game
        var teamPlace: Int?
        var teamScore: Int?
        var teamCoins: Int?
        var zonesClaimed: Int?
        var teamColor: String?
        var teamName: String?
    }
}

@available(iOS 16.2, *)
struct InGameWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: InGameWidgetAttributes.self) { context in
            VStack {
                switch context.state.gameStatus {
                case "pending":
                    PendingGameView(attributes: context.attributes, state: context.state)
                case "live":
                    LiveGameView(attributes: context.attributes, state: context.state)
                case "ended":
                    EndedGameView(attributes: context.attributes, state: context.state)
                default:
                    Text("Game Status: \(context.state.gameStatus)")
                }
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    switch context.state.gameStatus {
                    case "pending":
                        PendingGameView(attributes: context.attributes, state: context.state)
                    case "live":
                        LiveGameView(attributes: context.attributes, state: context.state)
                    case "ended":
                        EndedGameView(attributes: context.attributes, state: context.state)
                    default:
                        Text("Game Status: \(context.state.gameStatus)")
                    }
                }
            } compactLeading: {
                if context.state.gameStatus == "live" {
                    Text("Live")
                        .foregroundColor(.green)
                } else if context.state.gameStatus == "pending" {
                    Text("Waiting")
                        .foregroundColor(.orange)
                } else {
                    Text("Ended")
                        .foregroundColor(.red)
                }
            } compactTrailing: {
                if context.state.gameStatus == "live" {
                    Text("\(context.state.timeLeftMinutes)m").foregroundColor(.green).bold()
                } else if context.state.gameStatus == "pending" {
                    Text("\(context.state.playerCount)/\(context.state.maxPlayers)")
                } else {
                    Text("\(context.state.teamScore! + context.state.teamCoins!)")
                }
            } minimal: {
                Text(context.state.gameId)
            }
        }
    }
}

struct PendingGameView: View {
    var attributes: InGameWidgetAttributes
    var state: InGameWidgetAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                    Text("ClaimRush").fontWeight(.black).foregroundColor(.yellow).padding(8).italic()
                }.fixedSize()
                Spacer()
                HStack {
                    Circle().frame(width: 12, height: 12).foregroundColor(.orange).blur(radius: 2)
                    Text("Not Started").foregroundColor(.orange)
                }
            }
            HStack {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                }.frame(width: 50)
                Text("Game Code")
                Spacer()
                Text(state.gameId).bold()
            }.padding(2)
            HStack {
                HStack {
                    Image(systemName: "person.3.fill")
                }.frame(width: 50)
                Text("Players")
                Spacer()
                Text("\(state.playerCount) / \(state.maxPlayers)").bold()
            }.padding(2)
            HStack {
                HStack {
                    Image(systemName: "timer.circle.fill")
                }.frame(width: 50)
                Text("Duration")
                Spacer()
                Text("\(state.durationMinutes) min").bold()
            }.padding(2)
        }
        .padding()
    }
}

struct LiveGameView: View {
    var attributes: InGameWidgetAttributes
    var state: InGameWidgetAttributes.ContentState
    
    

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                    Text("ClaimRush").fontWeight(.black).foregroundColor(.yellow).padding(8).italic()
                }.fixedSize()
                Spacer()
                HStack {
                    Circle().frame(width: 12, height: 12).foregroundColor(.green).blur(radius: 2)
                    Text("In Game").foregroundColor(.green)
                }
            }
            HStack {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                }.frame(width: 50)
                Text("Game Code")
                Spacer()
                Text(state.gameId).bold()
            }.padding(2)
            HStack {
                HStack {
                    Image(systemName: "timer.circle.fill")
                }.frame(width: 50)
                Text("Time Left")
                Spacer()
                Text("\(state.timeLeftMinutes) min").bold()
            }.padding(2)
            Divider()
            HStack {
                HStack {
                    ZStack {
                        Circle().frame(width: 20, height: 20).foregroundColor(.black)
                        Text("\(state.teamPlace ?? 0)").foregroundColor(.white).fontWeight(.black)
                    }
                    Text(state.teamName ?? "").bold()
                }
                Spacer()
                HStack {
                    Text("\(state.teamScore ?? 0)")
                    Image(systemName: "trophy.fill")
                }
                Divider().frame(height: 20)
                HStack {
                    Text("\(state.teamCoins ?? 0)")
                    Image(systemName: "dollarsign.circle.fill")
                }
            }.padding(2)
        }
        .padding()
    }
}

struct EndedGameView: View {
    var attributes: InGameWidgetAttributes
    var state: InGameWidgetAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                    Text("ClaimRush").fontWeight(.black).foregroundColor(.yellow).padding(8).italic()
                }.fixedSize()
                Spacer()
                HStack {
                    Circle().frame(width: 12, height: 12).foregroundColor(.red).blur(radius: 2)
                    Text("Ended").foregroundColor(.red)
                }
            }
            HStack {
                HStack {
                    ZStack {
                        Circle().frame(width: 20, height: 20).foregroundColor(.black)
                        Text("\(state.teamPlace ?? 0)").foregroundColor(.white).fontWeight(.black)
                    }
                    Text(state.teamName ?? "").bold()
                }
                Spacer()
                HStack {
                    Text("\(state.teamScore ?? 0)")
                    Image(systemName: "trophy.fill")
                }
                Divider().frame(height: 20)
                HStack {
                    Text("\(state.teamCoins ?? 0)")
                    Image(systemName: "dollarsign.circle.fill")
                }
            }.padding(2)
        }
        .padding()
    }
}

@available(iOS 16.2, *)
struct InGameWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = InGameWidgetAttributes()
    static let contentState = InGameWidgetAttributes.ContentState(
        gameId: "SZJRWV",
        gameName: "Universal Studios Hollywood Scavenger Hunt",
        hostName: "samskulsky",
        startTime: Date().addingTimeInterval(300), // Adds 5 minutes to the current time
        endTime: Date().addingTimeInterval(5400), // Adds 1.5 hours to the current time
        gameStatus: "pending",
        playerCount: 3,
        maxPlayers: 6,
        durationMinutes: 90,
        timeLeftMinutes: 30,
        teamPlace: 1,
        teamScore: 120,
        teamCoins: 15,
        zonesClaimed: 2,
        teamColor: "blue",
        teamName: "Team Test"
    )

    static var previews: some View {
        Group {
            PendingGameView(attributes: attributes, state: contentState)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Pending Game")

            LiveGameView(attributes: attributes, state: contentState)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Live Game")

            EndedGameView(attributes: attributes, state: contentState)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Ended Game")
        }
    }
}
