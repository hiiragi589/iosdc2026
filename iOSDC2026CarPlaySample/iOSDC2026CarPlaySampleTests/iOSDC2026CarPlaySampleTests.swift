//
//  iOSDC2026CarPlaySampleTests.swift
//  iOSDC2026CarPlaySampleTests
//
//  Created by Kohei Nishi on 2026/07/05.
//

import Testing
@testable import iOSDC2026CarPlaySample

struct iOSDC2026CarPlaySampleTests {

    @Test func playbackRateAcceptsOnlyThePublishedRates() {
        let player = AudioPlayer()

        #expect(player.supportedPlaybackRates == [1.0, 1.25, 1.5, 2.0])
        #expect(player.setPlaybackRate(1.5))
        #expect(player.rate == 1.5)
        #expect(!player.setPlaybackRate(1.75))
        #expect(player.rate == 1.5)
    }

}
