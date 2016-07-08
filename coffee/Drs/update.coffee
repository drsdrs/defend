(if !inits? then inits = [] else inits).push
  update: ->
    that = @game.parent
    @physics.arcade.collide(
      that.attackers, that.player, that.enemyHitPlayer
    )
    @physics.arcade.collide(
      that.weapons, that.attackers, that.bulletHitEnemy
    )
    that.playerBrainThink()


inits.push playerBrainLevel: 1
inits.push playerBrainThink: -> @playerBrain @playerBrainLevel

inits.push playerBrain: (brainLvl)->
  if brainLvl==0  # LEVEL 0
    @player.body.angularVelocity = Math.sin((@game.time.time)/1000)*250
    @fire()
  else if brainLvl==1  # LEVEL 0
    if !@player.enemyToAttack?
      @player.enemyToAttack = @attackers.getClosestTo @player
      angle = @game.physics.arcade.angleBetween(
        @player.enemyToAttack
        @player
      )
      #@player.rotation = Math.PI/2+angle
      @player.rotationTarget = Math.PI/2+angle
      @player.body.angularVelocity = 200#Math.PI/2+angle
    else # attack or rotate
      rot = (@player.rotationTarget-@player.rotation)*50
      if !@player.enemyToAttack.alive
        @player.enemyToAttack = null
      else
        @fire()


inits.push bulletHitEnemy: (bullet, target)->
  that = drs#@game.parent
  bullet.kill()
  target.stats.life -= bullet.parent.power
  that.emitter.x = target.x
  that.emitter.y = target.y
  if target.stats.life <= 0
    target.kill()
    that.player.enemyToAttack = null
    val0 = if Math.random()>.5 then that.gameWidth+16 else -16
    trgPos = if Math.random()>.5
      x: val0
      y: Math.random()*that.gameWidth
    else
      x: Math.random()*that.gameWidth
      y: val0
    that.addAttacker trgPos
    that.emitter.explode(500, 25)
  else
    that.emitter.explode(80, 3)

    that.game.physics.arcade.moveToXY(
      target
      that.gameWidth/2, that.gameWidth/2
      that.game.rnd.between 10, 70
    )
    angle = (Math.PI/2+Math.atan2(
      target.y-that.gameWidth/2
      target.x-that.gameWidth/2
    ))#*(180/Math.PI)
    target.rotation = angle


inits.push enemyHitPlayer: (enemy, player)->
  console.log 'ouch'
