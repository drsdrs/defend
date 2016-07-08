(if !inits? then inits = [] else inits).push
  addAttacker: (pos, type, lvl)->
    enemyType = type||@game.rnd.pick([0..3])
    att = @attackers.create(
      pos.x
      pos.y
      'enemys'
      enemyType
    )
    att.enemyType = enemyType
    att.animations.add(
      'attack'
      [enemyType*4..enemyType*4+3]
      7, true
    )
    att.animations.play 'attack'
    #att.body.setSize 8, 8, 0, 0
    @game.physics.arcade.enable att
    #att.body.allowGravity = false
    #att.body.immovable = true
    #att.body.enable = false

    att.smoothed = false
    att.anchor.set(0.5)
    @game.physics.arcade.moveToXY(
      att
      @gameWidth/2, @gameWidth/2
      @game.rnd.between 10, 70
    )
    angle = (Math.PI/2+Math.atan2(
      pos.y-@gameWidth/2
      pos.x-@gameWidth/2
    ))#*(180/Math.PI)
    att.rotation = angle
    att.stats =
      spd: 0
      acc: 0
      life: 100
