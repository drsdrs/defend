(if !inits? then inits = [] else inits).push
  createBullet: ->
    @bullets = @game.add.group()
    @bullets.enableBody = true
    @bullets.physicsBodyType = Phaser.Physics.ARCADE

    @bullets.createMultiple(50, 'bullet')
    @bullets.setAll('checkWorldBounds', true)
    @bullets.setAll('outOfBoundsKill', true)
    @bullets.setAll('anchor.x', 0.5)
    @bullets.setAll('anchor.y', 0.5)
