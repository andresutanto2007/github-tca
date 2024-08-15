//
//  AvatarView.swift
//  GitHubTCA
//
//  Created by Andre on 2024/08/14.
//

import SwiftUI

struct AvatarView: View {
    private let imageSize: CGSize
    private let imageURL: URL?
    
    init(imageURL: URL?, imageSize: CGSize = .init(width: 80, height: 80)) {
        self.imageURL = imageURL
        self.imageSize = imageSize
    }
    
    var body: some View {
        imageView
            .frame(width: imageSize.width, height: imageSize.height)
            .cornerRadius(imageSize.width / 2)
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        } else {
            Color.red
        }
    }
}
