//
//  M3UParser.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 3/3/26.
//

import Foundation

enum M3UParser {
    static func parse(_ text: String) -> [Channel] {
        var channels: [Channel] = []
        var pendingName: String?
        
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
        
        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            
            if line.hasPrefix("#EXTINF") {
                if let commaIndex = line.firstIndex(of: ",") {
                    let namePart = line[line.index(after:commaIndex)...]
                    let name = namePart.trimmingCharacters(in: .whitespacesAndNewlines)
                    pendingName = name.isEmpty ? "Canal" : name
                } else {
                    pendingName = "Canal"
                }
                continue
            }
            
            if line.hasPrefix("#") { continue }
            
            if let url = URL(string: line) {
                let name = pendingName ?? url.host ?? "Canal"
                channels.append(Channel(name: name, url: url))
            }
            pendingName = nil
        }
        return channels
    }
}
