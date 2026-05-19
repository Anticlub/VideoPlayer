//
//  Constant.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 19/5/26.
//

import Foundation

enum Constants {
    enum Streams {
        static let tdtSpain = URL(string: "https://www.tdtchannels.com/lists/tv_mpd.m3u8")!
        static let axinomDrmClear = URL(string: "https://media.axprod.net/TestVectors/v9-MultiFormat/Clear/Manifest_1080p.m3u8")!
        static let axinomDrmTest = URL(string: "https://media.axprod.net/TestVectors/v9-MultiFormat/Encrypted_Cbcs/Manifest_1080p.m3u8")!
    }
    
}
