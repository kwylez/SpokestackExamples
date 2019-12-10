# SpokestackExamples

## SpokestackRSSReader

The SpokestackRSSReader showcases Spokestack's Text-to-Speech (TTS) functionality by taking a feed's headlines, processing them with Spokestack's TTS service and responding with a "natural voice" utterance.

## Requirements

* iOS 13+
* Xcode 11+

## Dependencies

* Spokestack (installed via CocoaPods)
* FeedKit (installed via CocoaPods)

## Setup

```
git clone https://github.com/kwylez/SpokestackExamples
cd SpokestackExamples/SpokestackRSSReader
gem install cocoapods
pod install
open SpokestackRSSReader.xcworkspace
```

The customizations to the sample app include ([SpokestackRSSReader/SpokestackRSSReader/Configs/App.swift](SpokestackRSSReader/SpokestackRSSReader/Configs/App.swift)):

* The welcome message: What is read when the app starts up
* Action delay: Time delay (in seconds) between reading each headline
* Action Phrase: Button text on each item card. i.e. "Tell me more"
* Finished message: Message that is read when all headlines have been read
* Heading: Text for navigation bar
* Feed URL: Link to the RSS feed that you want to process
* Number of Feed Items to display: Defaults to 5
