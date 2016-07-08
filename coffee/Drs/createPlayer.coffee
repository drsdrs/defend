(if !inits? then inits = [] else inits).push
  createPlayer: ->
    @player =
      @game.add.sprite @gameWidth/2, @gameWidth/2, 'player', 0
    @player.anchor.set(0.5)
    @player.enableBody = true


    @player.physicsBodyType = Phaser.Physics.arcade
    @game.physics.enable @player, Phaser.Physics.ARCADE
    @player.body.immovable = true
    @player.stats =
      rotationSpeed: 20
