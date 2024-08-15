//
//  CommonAlert.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import ComposableArchitecture

struct CommonAlert {
    @Reducer
    struct ErrorFeature {
        typealias State = AlertState<Action>
        enum Action {
            case onTapRefreshButton
        }
        
        static func buildAlert(error: Error) -> ErrorFeature.State {
            return AlertState {
                TextState("common_error_alert_title")
            } actions: {
                ButtonState(action: .onTapRefreshButton) {
                    TextState("common_error_alert_refresh")
                }
            } message: {
                TextState(error.localizedDescription)
            }
        }
    }
}
