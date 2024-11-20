
//
//  ChatListView.swift
//  Swift_ASP
//  Created by chou on 2024/11/19.
//
import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct ChatListView: View {
    
    @StateObject private var viewModel: ChatChannelListViewModel
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()
    @State private var chatApi = ChatApi()
    public init(
        channelListController: ChatChannelListController? = nil
    ) {
        let channelListVM = ViewModelsFactory.makeChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )
        _viewModel = StateObject(
            wrappedValue: channelListVM
        )
    }
    
    var body: some View {
        Text("Chat Screen")
                    .onAppear {
                        chatApi.connectUser()
                    }
        NavigationView {
            ChannelList(
                factory: DefaultViewFactory.shared,
                channels: viewModel.channels,
                selectedChannel: $viewModel.selectedChannel,
                swipedChannelId: $viewModel.swipedChannelId,
                onItemTap: { channel in
                    viewModel.selectedChannel = channel.channelSelectionInfo
                },
                onItemAppear: { index in
                    viewModel.checkForChannels(index: index)
                },
                channelDestination: DefaultViewFactory.shared.makeChannelDestination()
            )
            .toolbar {
                DefaultChatChannelListHeader(title: "Stream Tutorial")
            }
        }
    }
}
