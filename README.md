# Description

![Loading](https://github.com/robinsalehjan/showmeads/blob/master/Images/1.png) ![Loaded](https://github.com/robinsalehjan/showmeads/blob/master/Images/2.png) ![Favorites](https://github.com/robinsalehjan/showmeads/blob/master/Images/3.png)

## Folders
- UI: Customized UI elements
- Controllers: Application logic
- Extensions: Useful functions for `UIKit` and `Foundation` classes
- Library: Reusable classes and functions
- Sources: Components such as network/database service
- Resources: Application resources, images and so on

## Classes
- `AppDelegate`: Initalizes an instance of `UINavigationController` with an instance of the `AdStateViewController` class as the root view controller

- `AdStateViewController`: The parent view controller manages the different states the app  can be in: `loading`, `loaded` and `error`
- `AdCollectionViewController`: When the app is in a `loaded` state the parent view controller will present this collection view
- `AdLoadingViewController`: When the app is in a `loading` state the parent view controller presents this view.
- `AdErrorStateViewController`: When the app is in a `error` state the parent view controller presents this view.
- `AdsFacade`: A `Facade` abstraction with an simpler interface for the `AdService` and `AdPersistenceService` services
  - `AdService`: Responsible for fetching and parsing the response from the API to entities.
  - `AdPersistenceService`: Responsible for fetching, saving and deleting entities to and from Core Data
- `CacheFacade`: A `Facade` abstraction for the underlying `AdImageCacheService` and `DiskCacheService`
  - `AdImageCacheService`: In-memory cache maps the `imageURL` to the `Data` for every entity.
  - `DiskCacheService`: Caches images to disk.
