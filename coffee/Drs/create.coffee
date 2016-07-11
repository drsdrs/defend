(if !inits? then inits = [] else inits).push
  create: ->
    showGameHideLoader()
    that = @game.parent
    @physics.startSystem Phaser.Physics.ARCADE
    @stage.smoothed = false
    @scale.scaleMode = Phaser.ScaleManager.SHOW_ALL

    that.btnInput = @input.keyboard.createCursorKeys()
    that.createPlayer()
    that.createWeapons()


    @game.add.image(0, 0, 'pixel')

    that.emitter = @game.add.emitter @game.world.centerX, @game.world.centerY, 50

    that.emitter.width = 0
    that.emitter.gravity = 0
    #that.emitter.setRotation(0, 45)
    that.emitter.setAlpha(.2, 0.8)
    that.emitter.setScale(5, 6, 5, 6)
    that.emitter.setXSpeed -600, 600
    that.emitter.setYSpeed -600, 600
    that.emitter.makeParticles('pixel')


    that.attackers = @add.group()
    that.attackers.enableBody = true
    that.attackers.physicsBodyType = Phaser.Physics.arcade
    for i in [0..8]
      val0 = if Math.random()>.5 then that.gameWidth+16 else -16
      trgPos = if Math.random()>.5
        x: val0
        y: Math.random()*that.gameWidth
      else
        x: Math.random()*that.gameWidth
        y: val0
      that.addAttacker trgPos


showGameHideLoader = ->
  loader = document.getElementById('loader')
  game = document.getElementById('game')
  canvas = document.getElementsByTagName('canvas')[0]
  document.getElementById('gameContainer').appendChild canvas

  loader.classList.add 'hide'
  loader.classList.remove 'show'
  game.classList.add 'show'
  game.classList.remove 'hide'
