//
//  M3UParserTest.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 18/5/26.
//

import Testing
@testable import VideoPlayer
import Foundation

@Test @MainActor func m3uParser_withValidText_returnsChannels() {
    let m3uText = """
        #EXTM3U
        #EXTINF:-1,Canal Test
        https://test.com/stream
        """
    let channels = M3UParser.parse(m3uText)
    #expect(channels.count == 1)
    #expect(channels[0].name == "Canal Test")
}

@Test @MainActor func m3uParser_withInvalidText_returnsEmptyArray() {
    let m3uText = "This is not a valid M3U file."
    let channels = M3UParser.parse(m3uText)
    #expect(channels.isEmpty)
}

@Test @MainActor func m3uParser_withEmptyText_returnsEmptyArray() {
    let m3uText = ""
    let channels = M3UParser.parse(m3uText)
    #expect(channels.isEmpty)
}

@Test @MainActor func m3uParser_withTvgGroup_returnsChannelsWithGroup() {
    let m3uText = """
    #EXTM3U
    #EXTINF:-1 group-title="Generalista" ,Canal Test
    https://test.com/stream
    """
    let channels = M3UParser.parse(m3uText)
    #expect(channels[0].groupTitle == "Generalista")
}

@Test @MainActor func m3uParser_withTvgLogo_returnsChannelWithLogo() {
    let m3uText = """
    #EXTM3U
    #EXTINF:-1 tvg-logo="https://logo.com/logo.png",Canal Test
    https://test.com/stream
    """
    let channels = M3UParser.parse(m3uText)
    #expect(channels[0].logoURL == URL(string: "https://logo.com/logo.png"))
}

@Test @MainActor func m3uParser_with_multiple_channels() {
    let m3uText = """
        #EXTM3U
        #EXTINF:-1,Canal Test
        https://test.com/stream
        #EXTINF:-1,Canal Test 2
        https://test.com/stream
        """
    let channels = M3UParser.parse(m3uText)
    #expect(channels.count == 2)
    #expect(channels[0].name == "Canal Test")
    #expect(channels[1].name == "Canal Test 2")
}

@Test @MainActor func m3uParser_withEmptyChannelName_returnsDefaultName() {
    let m3uText = """
        #EXTM3U
        #EXTINF:-1,
        https://test.com/stream
        """
    let channels = M3UParser.parse(m3uText)
    #expect(channels[0].name == "Canal")
}

@Test @MainActor func m3uParser_withNonHttpURL_returnsEmptyArray() {
    let m3uText = """
        #EXTM3U
        #EXTINF:-1, Canal Test
        ftp://test.com/stream
        """
    let channels = M3UParser.parse(m3uText)
    #expect(channels.isEmpty)
}

@Test @MainActor func m3uParser_withMissingURL_returnsEmptyArray() {
    let m3uText = """
    #EXTM3U
    #EXTINF:-1 tvg-logo="https://logo.com/logo.png",Canal Test
    """
    let channels = M3UParser.parse(m3uText)
    #expect(channels.isEmpty)
}
