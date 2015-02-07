# Warehouse:beers:

You can use easily NSFileManager.

## How to use

```swift
var path = Warehouse.documentDirectoryPath()
path = path + "/hey/hey.txt"

let warehouse = Warehouse()
warehouse.subDirectoryPath = "/Test"

warehouse.saveFile(fileName: "Muukii", contents: NSData(), success: { (savedRelativePath) -> Void in

}) { (error) -> Void in

}
```

### Generate Warehouse instance for each category.

```swift
let warehouseForImage = Warehouse()
let warehouseForAudio = Warehouse()
let warehouseForMovie = Warehouse()
```

```swift
warehouseForImage.saveFile(fileName: "imageFile", contents: NSData(), success: { (savedRelativePath) -> Void in

}) { (error) -> Void in

}


warehouseForAudio.saveFile(fileName: "audioFile", contents: NSData(), success: { (savedRelativePath) -> Void in

}) { (error) -> Void in

}
```
