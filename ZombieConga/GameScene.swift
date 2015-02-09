//
//  GameScene.swift
//  ZombieConga
//
//  Created by Emiliano on 1/6/15.
//  Copyright (c) 2015 eviera.net. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    
    /// Vector velocidad
    var velocity = CGPointZero
    
    /// Area de juego
    let playableRect: CGRect
    
    //Ultima posicion tocada
    var lastTouchLocation = CGPointZero
    
    
    ///
    /// Al inicio, calculo el area jugable
    ///
    override init(size: CGSize) {
        
        //El maximo aspect ratio soportado (soporta desde 3:2 = 1.33 hasta 16:9 = 1.77)
        let maxAspectRatio:CGFloat = 16.0 / 9.0

        //El ancho del area jugable no cambia con .AspectFill, pero si el alto. Aca calculo el nuevo alto del area jugable usando el ancho (ancho / ratio = alto)
        let playableHeight = size.width / maxAspectRatio
        
        //Calculo el margen que hay que dejar arriba y abajo
        let playableMargin = (size.height - playableHeight) / 2.0
        
        /*
        Armo un rectangulo centrado en la pantalla
    
        +----------------------+
        +----------------------+
        |                      |
        |    playableRect      |  playableHeight
        |                      |
        +----------------------+  y=playableMargin
        +----------------------+
        x=0
             width (no cambia)
        
        */
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }
    
    ///
    ///Este es para usar el scene editor. No se usa
    ///
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    /// Se inicializa la vista
    ///
    override func didMoveToView(view: SKView) {
        backgroundColor  = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        
    }
    
    
    ///
    /// Mueve el zombie a la velocidad calculada en cada frame update (velocidad * dt)
    ///
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        
        //Vector velocidad por tiempo
        //let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        let amountToMove = velocity * CGFloat(dt)
        //println("Amount to move: \(amountToMove)")
        
        //Suma el vector velocidad por tiempo a la posicion original del zombie
        //sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
        sprite.position += amountToMove
    }
    
    ///
    /// Se ejecuta en cada actualizacion del frame
    /// Mueve el zombie a una nueva posicion y calcula el diferencial de tiempo que paso (dt) para el proximo movimiento
    ///
    override func update(currentTime: NSTimeInterval) {
        
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        

        //Calculo la distancia desde donde esta el zombie hasta donde se toco la pantalla
        let zombieToTouch: CGPoint = lastTouchLocation - zombie.position
        
        //Calculo el largo que deberia moverse el zombie en este frame
        let zombieDistanceToTravel: CGFloat = zombieMovePointsPerSec * CGFloat(dt)
        
        
        if zombieToTouch.length() <= zombieDistanceToTravel {
            zombie.position = lastTouchLocation
            velocity = CGPointZero
            
        } else {

            moveSprite(zombie, velocity: velocity)
        
            
            //Rota al zombie en el angulo del vector velocidad
            rotateSprite(zombie, direction: velocity)
        }
        
        
        //Chequea siempre si se pega contra los bordes
        boundsCheckZombie()
        
    }
    
    
    ///
    /// Recalcula el vector velocidad cada vez que se toca en un punto de la pantalla (el nombre de la funcion original esta mal)
    /// Este metodo se llamaba moveZombieToward(location: CGPoint)
    ///
    func recalculateVelocity(location: CGPoint) -> CGPoint {
        
        //vector diferencia entre el punto tocado y la posicion del zombie
        //let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)
        let offset = location - zombie.position
        
        //largo del vector diferencia
        //let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        
        //normalizacion del vector (vector de largo 1)
        //let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        let direction = offset / offset.length()
        
        //para calcular la magnitud del vector velocidad multiplico el normalizado por la velocidad que quiero
        //velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
        let velocity = direction * zombieMovePointsPerSec
        
        return velocity
    }

    
    ///
    /// Comprueba si choca contra los bordes y le cambia el sentido
    ///
    func boundsCheckZombie() {
        //Uso el area de juego como referencia
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
                zombie.position.y = topRight.y
                velocity.y = -velocity.y
        }
    }
    
    
    ///
    /// Rota a un sprite segun el angulo del vector direction (angulo = arctan (opuesto / adyacente))
    ///
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        //sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
        sprite.zRotation = direction.angle
    }
    
    ///
    /// Al tocar en un punto de la pantalla llama a recalcular el vector velocidad
    ///
    func sceneTouched(touchLocation: CGPoint) {
        //Guardo la posicion donde se toco
        lastTouchLocation = touchLocation
        
        //Recalcula y asigna la nueva velocidad
        velocity = recalculateVelocity(touchLocation)
    }
    
    
    ///
    ///Helper touch
    ///
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    ///
    ///Helper touch
    ///
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
}
