//
//  M3UParserTest.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 18/5/26.
//

import Testing
@testable import VideoPlayer
import Foundation

@Test @MainActor func m3uParser_withValidText_returnsChannels() async throws {
    let m3uText = """
        #EXTM3U
        #EXTINF:-1,Canal Test
        https://test.com/stream
        """
    let channels = M3UParser.parse(m3uText)
    #expect(channels.count == 1)
    #expect(channels[0].name == "Canal Test")
}

@Test @MainActor func m3uParser_withInvalidText_returnsEmptyArray() async throws {
    let m3uText = "This is not a valid M3U file."
    let channels = M3UParser.parse(m3uText)
    #expect(channels.isEmpty)
}

@Test @MainActor func m3uParser_withEmptyText_returnsEmptyArray() async throws {
    let m3uText = ""
    let channels = M3UParser.parse(m3uText)
    #expect(channels.isEmpty)
}

@Test @MainActor func m3uParser_withTvgGroup_returnsChannelsWithGroup() async throws {
    let m3uText = """
    #EXTM3U
    #EXTINF:-1 group-title="Generalista" ,Canal Test
    https://test.com/stream
    """
    let channels = M3UParser.parse(m3uText)
    #expect(channels[0].groupTitle == "Generalista")
}

@Test @MainActor func m3uParser_withTvgLogo_returnsChannelWithLogo() async throws {
    let m3uText = """
    #EXTM3U
    #EXTINF:-1 tvg-logo="https://logo.com/logo.png",Canal Test
    https://test.com/stream
    """
    let channels = M3UParser.parse(m3uText)
    #expect(channels[0].logoURL == URL(string: "https://logo.com/logo.png"))
}
