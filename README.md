# github-tca

An iOS application built with SwiftUI, The Composable Architecture (TCA), and modular architecture. The app displays a list of GitHub users, detailed user information, their repositories, and a web view for browsing repositories.

## Features

- **User List**: Displays a list of GitHub users fetched from the GitHub API.
- **User Repositories**: Shows detailed information and a list of repositories for a selected user.
- **WebView**: Opens a web view when a user selects one of the repositories, allowing them to view the repository details.

## Technology Stack

- **SwiftUI**: Declarative UI framework for building the user interface.
- **TCA (The Composable Architecture)**: Utilized for managing app state, side effects, and business logic in a consistent and modular way.
- **Modular Architecture**: The app is divided into multiple modules to ensure scalability, maintainability, and testability.
- **Unit Tests & Snapshot Tests**: Ensures the correctness of the code and visual elements.

## Getting Started

### Prerequisites

- Xcode 14 or later.
- Swift 5.7 or later.
- A GitHub account (optional but recommended for increasing API rate limits).

### Installation

1. Clone the repository to your local machine:
    ```bash
    git clone https://github.com/andresutanto2007/github-tca
    cd github-tca
    ```

2. Open the project in Xcode:
    ```bash
    open github-tca.xcworkspace
    ```

3. Install the project dependencies using Swift Package Manager (SPM). You should see the packages being resolved automatically upon opening the project in Xcode.

### GitHub API Rate Limits

The GitHub API imposes a rate limit of 60 requests per hour for unauthenticated requests. If you encounter server errors, you may have reached the rate limit.

To increase the rate limit, you can use an access token. Follow these steps to generate a GitHub access token:

1. [Get an Access Token](https://docs.github.com/en/rest/quickstart?apiVersion=2022-11-28#oauth)
2. Once you have the access token, add it to the `Info.plist` with key `GITHUB_ACCESS_TOKEN`

By using an access token, the rate limit increases significantly, allowing for a smoother experience.
