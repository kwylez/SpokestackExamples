# SpokestackExamples

## SpokestackRSSReader

The SpokestackRSSReader showcases Spokestack's Text-to-Speech (TTS) functionality by taking a feed's headlines, processing them with Spokestack's TTS service and responding with a "natural voice" utterance.

## Requirements

* iOS 13+
* Xcode 11+

## Dependencies

**Spokestack via CocoaPods**

Open your terminal

```
cd /path/to/SpokestackExamples/SpokestackRSSReader
pod install
```

This will add the latest version to project.

**FeedKit via SPM**

To parse the RSS feed the project utilizes [FeedKit](https://github.com/nmdias/FeedKit)

## Setup

The customizations to the sample app include ([SpokestackRSSReader/SpokestackRSSReader/Configs/App.swift](SpokestackRSSReader/SpokestackRSSReader/Configs/App.swift)):

* The welcome message: What is read when the app starts up
* Action delay: Time delay (in seconds) between reading each headline
* Action Phrase: Button text on each item card. i.e. "Tell me more"
* Finished message: Message that is read when all headlines have been read
* Heading: Text for navigation bar
* Feed URL: Link to the RSS feed that you want to process
