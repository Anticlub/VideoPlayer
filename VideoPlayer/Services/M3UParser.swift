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
        var pendingLogoURL: URL?
        var pendingGroupTitle: String?
        
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
                
                if let logoString = extractAttribute("tvg-logo", from: line),
                   let logtoURL = URL(string: logoString) {
                    pendingLogoURL = logtoURL
                } else {
                    pendingLogoURL = nil
                }
                
                pendingGroupTitle = extractAttribute("group-title", from: line)
                
                continue
            }
            
            if line.hasPrefix("#") { continue }
            
            if let url = URL(string: line) {
                let name = pendingName ?? url.host ?? "Canal"
                channels.append(Channel(name: name, url: url))
            }
            pendingName = nil
            pendingLogoURL = nil
            pendingGroupTitle = nil
        }
        return channels
    }
    
    private static func extractAttribute(_ key: String, from line: String) -> String? {
        
        guard let range = line.range(of: "\(key)=\"") else {return nil}
        let start = range.upperBound
        guard let end = line[start...].firstIndex(of: "\"") else {return nil}
        return String(line[start..<end])
    }
}
