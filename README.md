# VideoPlayer tvOS

A simple tvOS video player prototype built with **SwiftUI** that
supports:

-   HLS playback
-   Direct stream playback
-   FairPlay DRM streams
-   Channel playlists (M3U)
-   Custom playback controls

This project was built as part of a learning process for **video
streaming and DRM integration**.

------------------------------------------------------------------------

# Features

-   HLS playback using `AVPlayer`
-   FairPlay DRM support via `AVAssetResourceLoader`
-   Playlist loading (M3U)
-   Channel selection UI
-   Custom playback controls
-   Focus navigation for tvOS
-   Modular architecture

------------------------------------------------------------------------

# Architecture

The project follows a simple MVVM-style structure.

Models ├─ Channel\
├─ DRMConfiguration\
├─ PlaybackSource\
└─ PlaylistSource

Services ├─ PlayerService\
└─ DRMManager

ViewModels └─ PlayerViewModel

Views ├─ ContentView\
├─ PlayerView\
├─ PlayerControlsView\
├─ ChannelListView\
└─ ChannelCardView

### Responsibilities

**PlayerService** - Creates `AVPlayer` - Loads playback sources -
Handles play / pause / stop

**DRMManager** - Handles FairPlay DRM requests - Generates SPC -
Requests CKC from license server

**PlayerViewModel** - Manages playlists - Manages channels - Controls
playback state

**Views** - SwiftUI interface - Focus navigation - Player controls

------------------------------------------------------------------------

# FairPlay DRM Flow

AVPlayer loads HLS manifest\
↓\
Manifest contains skd:// key\
↓\
AVAssetResourceLoaderDelegate intercepts request\
↓\
DRMManager generates SPC\
↓\
SPC sent to license server\
↓\
Server returns CKC\
↓\
AVPlayer receives CKC\
↓\
Playback continues

------------------------------------------------------------------------

# Test Streams

The project includes test streams for experimentation:

-   Clear HLS stream
-   DRM protected HLS stream (FairPlay test vector)

Example DRM test stream:

https://media.axprod.net/TestVectors/v9-MultiFormat/Encrypted_Cbcs/Manifest_1080p.m3u8

------------------------------------------------------------------------

# Requirements

-   Xcode
-   tvOS target
-   Apple device recommended for FairPlay testing

Note:\
FairPlay DRM may not work correctly in the **simulator**.

------------------------------------------------------------------------

# Learning Goals

This project was built to learn:

-   HLS streaming
-   AVPlayer architecture
-   FairPlay DRM integration
-   Resource loader delegation
-   SwiftUI + tvOS focus navigation
-   Clean architecture separation

------------------------------------------------------------------------

# Future Improvements

Possible improvements:

-   Better playlist management
-   DRM configuration via API
-   More robust error handling
-   Better UI/UX for channel navigation

------------------------------------------------------------------------

# Author

Cristofer Fernandez
