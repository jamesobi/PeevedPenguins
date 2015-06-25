import Foundation


class MainScene: CCNode {
    
    func play() {
        println("play button pressed")
        
        let gameplayScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(gameplayScene)
        
        println("play is executed")
    }
}
