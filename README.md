# HabitTracker App

## Overview
An app for tracking regular habits/activities and occasional events.

## Features
- Add trackers for regular activities and occasional events
- Edit trackers and categories
- Filter and search trackers
- Track your stats
- Dark theme support
- Languge support (English, Russian)

## Tech Stack
- **Language:** Swift
- **Architecture:** MVC, MVVM
- **Frameworks:** UIKit, CoreData
- **Tools:** CocoaPods, SPM, SnapshotTesting, AppMetrica

## Installation
```bash
git clone https://github.com/BVladimir01/Tracker
cd Tracker
pod install
open Tracker.xcworkspace
```

### Requirements
- Swift 5.x
- iOS 13.4+
- Xcode 16+

## Preview

|Onboarding                   |Trackers creation                      |Trackers Filtering         |
|:---------------------------:|:-------------------------------------:|:-------------------------:|
|![Onboarding][onboarding_gif]|![Habits_creation][habits_creation_gif]|![Filtering][filtering_gif]|
|**Trackers editing**         |**Trackers search**                    |**Stats**                  |
|![Editing][editing_gif]      |![Searching][searching_gif]            |![Stats][stats_gif]        |

##  Project Structure

**TravelSchedule/** \
├ **StartupFlow/** *Top level app files* \
├ **OnboardingFlow/** *Onboarding pages* \
├ **TrackersList/** *Trackers list tab* \
├ **Stats/** *Stats tab* \
├ **DataBase/** *Database files* \
├ **UIHelpers/** *UI components and helpers* \
├ **Models/** *Global models* \
├ **Services/** *Global services* \
├ **Extensions/** *Extensions for base frameworks* \
├ **Resources/** *Images, Localizaiont, plist* \
**TrackerTests/** *Snapshot tests*

## Future plan
- [ ] Use MVVM throughout
- [ ] Improve project srtucture
- [ ] Add Unit tests
- [ ] Add UI tests
- [ ] Add documentation

## Acknowledgements
Big thanks to Yandex Practicum reviewers.


[onboarding_gif]: PreviewGIFs/onboarding.gif
[habits_creation_gif]: PreviewGIFs/habits_creation.gif
[filtering_gif]: PreviewGIFs/filtering.gif
[editing_gif]: PreviewGIFs/editing.gif
[searching_gif]: PreviewGIFs/searching.gif
[stats_gif]: PreviewGIFs/stats.gif