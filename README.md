# chuckle

のびしろチームのchuckleです

## フロント担当

* しゅー
* しもとり

## つかいかた

```Carthage/``` が丸ごとないので、最初に ```carthage update``` してください  
[Carthage](https://github.com/Carthage/Carthage)

## jsonのパースについて

[jsonサンプル](https://github.com/pixiv/summer-intern-2015-c-server)  
[はねけ](https://github.com/Haneke/HanekeSwift)

送られてくるjsonの形式をすべてモデル(protocolの ```Decodable``` が実装されたもの)として用意しておく必要があります  
しもとりがサボっていない限りは ```Models/``` にある

```swift
let decoded: モデル = decode([String: AnyObject])   //代入先の型明記必須
```

decodeArrayとかdecodeDictionaryもあるらしい。
