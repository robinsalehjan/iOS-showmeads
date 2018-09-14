# Description

![Loading](https://github.com/robinsalehjan/showmeads/blob/master/Images/1.png) ![Loaded](https://github.com/robinsalehjan/showmeads/blob/master/Images/2.png) ![Favorites](https://github.com/robinsalehjan/showmeads/blob/master/Images/3.png)

## Folders
- Library: Reusable code and abstractions.
- Extensions: Useful helper functions.
- UI: Views, Cell and other UI components.
- Controllers: Application logic.
- Services: Different services for networking, caching and persistency. 
- Resources: Application resources, images and fonts.

## Classes
- `AppDelegate`: Initalizes an instance of the `AdStateViewController` class and sets it as the root view controller of the window object.

- `AdStateViewController`: The parent view controller manages the different states the app can be in: `loading`, `loaded` and `error`
- `AdCollectionViewController`: When the app is in a `loaded` state the parent view controller will load this controller.
- `AdLoadingViewController`: When the app is in a `loading` state the parent view controller load this controller.
- `AdErrorStateViewController`: When the app is in a `error` state the parent view controller load this controller.

- `AdsService`:  A abstraction that provides data from the database, network or cache.
  - `AdNetworkService`:  Sends request to the backend and handles serialization.
  - `AdPersistenceService`: Responsible for fetching, saving and deleting entities to and from Core Data.
  - `AdImageCacheService`: In-memory cache maps  the `imageURL`  to an `Data` for every entity saved in Core Data.
  - `AdDiskCacheService`: Caches images to disk.
