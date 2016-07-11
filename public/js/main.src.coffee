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

#game = new (Phaser.Game)(640, 400, Phaser.AUTO, 'game')
#  Our core Bullet class
#  This is a simple Sprite object that we set a few properties on
#  It is fired by all of the Weapon classes

Bullet = (game, key) ->
  Phaser.Sprite.call this, game, 0, 0, key
  @texture.baseTexture.scaleMode = PIXI.scaleModes.NEAREST
  @anchor.set 0.5
  @checkWorldBounds = true
  @outOfBoundsKill = true
  @exists = false
  @tracking = false
  @scaleSpeed = 0
  return

Bullet.prototype = Object.create(Phaser.Sprite.prototype)
Bullet::constructor = Bullet

Bullet::fire = (x, y, angle, speed, gx, gy) ->
  gx = gx or 0
  gy = gy or 0
  @reset x, y
  @scale.set 1
  @game.physics.arcade.velocityFromAngle angle, speed, @body.velocity
  @angle = angle
  @body.gravity.set gx, gy
  return

Bullet::update = ->
  if @tracking
    @rotation = Math.atan2(@body.velocity.y, @body.velocity.x)
  if @scaleSpeed > 0
    @scale.x += @scaleSpeed
    @scale.y += @scaleSpeed
  return

Weapon = {}
#//////////////////////////////////////////////////
#  A single bullet is fired in front of the ship //
#//////////////////////////////////////////////////

Weapon.SingleBullet = (game) ->
  Phaser.Group.call this, game, game.world, 'Single Bullet', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 600
  @fireRate = 100
  i = 0
  while i < 64
    @add new Bullet(game, 'bullet5'), true
    i++
  this

Weapon.SingleBullet.prototype = Object.create(Phaser.Group.prototype)
Weapon.SingleBullet::constructor = Weapon.SingleBullet

Weapon.SingleBullet::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 10
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @nextFire = @game.time.time + @fireRate
  return

#///////////////////////////////////////////////////////
#  A bullet is shot both in front and behind the ship //
#///////////////////////////////////////////////////////

Weapon.FrontAndBack = (game) ->
  Phaser.Group.call this, game, game.world, 'Front And Back', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 600
  @fireRate = 100
  i = 0
  while i < 64
    @add new Bullet(game, 'bullet5'), true
    i++
  this

Weapon.FrontAndBack.prototype = Object.create(Phaser.Group.prototype)
Weapon.FrontAndBack::constructor = Weapon.FrontAndBack

Weapon.FrontAndBack::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 10
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 180, @bulletSpeed, 0, 0
  @nextFire = @game.time.time + @fireRate
  return

#////////////////////////////////////////////////////
#  3-way Fire (directly above, below and in front) //
#////////////////////////////////////////////////////

Weapon.ThreeWay = (game) ->
  Phaser.Group.call this, game, game.world, 'Three Way', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 600
  @fireRate = 100
  i = 0
  while i < 96
    @add new Bullet(game, 'bullet7'), true
    i++
  this

Weapon.ThreeWay.prototype = Object.create(Phaser.Group.prototype)
Weapon.ThreeWay::constructor = Weapon.ThreeWay

Weapon.ThreeWay::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 10
  y = source.y + 10
  @getFirstExists(false).fire x, y, 270, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 90, @bulletSpeed, 0, 0
  @nextFire = @game.time.time + @fireRate
  return

#///////////////////////////////////////////
#  8-way fire, from all sides of the ship //
#///////////////////////////////////////////

Weapon.EightWay = (game) ->
  Phaser.Group.call this, game, game.world, 'Eight Way', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 600
  @fireRate = 100
  i = 0
  while i < 96
    @add new Bullet(game, 'bullet5'), true
    i++
  this

Weapon.EightWay.prototype = Object.create(Phaser.Group.prototype)
Weapon.EightWay::constructor = Weapon.EightWay

Weapon.EightWay::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 16
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 45, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 90, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 135, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 180, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 225, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 270, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 315, @bulletSpeed, 0, 0
  @nextFire = @game.time.time + @fireRate
  return

#//////////////////////////////////////////////////
#  Bullets are fired out scattered on the y axis //
#//////////////////////////////////////////////////

Weapon.ScatterShot = (game) ->
  Phaser.Group.call this, game, game.world, 'Scatter Shot', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 600
  @fireRate = 40
  i = 0
  while i < 32
    @add new Bullet(game, 'bullet5'), true
    i++
  this

Weapon.ScatterShot.prototype = Object.create(Phaser.Group.prototype)
Weapon.ScatterShot::constructor = Weapon.ScatterShot

Weapon.ScatterShot::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 16
  y = source.y + source.height / 2 + @game.rnd.between(-10, 10)
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @nextFire = @game.time.time + @fireRate
  return

#////////////////////////////////////////////////////////////////////////
#  Fires a streaming beam of lazers, very fast, in front of the player //
#////////////////////////////////////////////////////////////////////////

Weapon.Beam = (game) ->
  Phaser.Group.call this, game, game.world, 'Beam', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 1000
  @fireRate = 45
  i = 0
  while i < 64
    @add new Bullet(game, 'bullet11'), true
    i++
  this

Weapon.Beam.prototype = Object.create(Phaser.Group.prototype)
Weapon.Beam::constructor = Weapon.Beam

Weapon.Beam::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 40
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @nextFire = @game.time.time + @fireRate
  return

#/////////////////////////////////////////////////////////////////////
#  A three-way fire where the top and bottom bullets bend on a path //
#/////////////////////////////////////////////////////////////////////

Weapon.SplitShot = (game) ->
  Phaser.Group.call this, game, game.world, 'Split Shot', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 700
  @fireRate = 40
  i = 0
  while i < 64
    @add new Bullet(game, 'bullet8'), true
    i++
  this

Weapon.SplitShot.prototype = Object.create(Phaser.Group.prototype)
Weapon.SplitShot::constructor = Weapon.SplitShot

Weapon.SplitShot::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 20
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, -500
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 500
  @nextFire = @game.time.time + @fireRate
  return

#/////////////////////////////////////////////////////////////////////
#  Bullets have Gravity.y set on a repeating pre-calculated pattern //
#/////////////////////////////////////////////////////////////////////

Weapon.Pattern = (game) ->
  Phaser.Group.call this, game, game.world, 'Pattern', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 600
  @fireRate = 40
  @pattern = Phaser.ArrayUtils.numberArrayStep(-800, 800, 200)
  @pattern = @pattern.concat(Phaser.ArrayUtils.numberArrayStep(800, -800, -200))
  @patternIndex = 0
  i = 0
  while i < 64
    @add new Bullet(game, 'bullet4'), true
    i++
  this

Weapon.Pattern.prototype = Object.create(Phaser.Group.prototype)
Weapon.Pattern::constructor = Weapon.Pattern

Weapon.Pattern::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 20
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, @pattern[@patternIndex]
  @patternIndex++
  if @patternIndex == @pattern.length
    @patternIndex = 0
  @nextFire = @game.time.time + @fireRate
  return

#/////////////////////////////////////////////////////////////////
#  Rockets that visually track the direction they're heading in //
#/////////////////////////////////////////////////////////////////

Weapon.Rockets = (game) ->
  Phaser.Group.call this, game, game.world, 'Rockets', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 400
  @fireRate = 250
  i = 0
  while i < 32
    @add new Bullet(game, 'bullet10'), true
    i++
  @setAll 'tracking', true
  this

Weapon.Rockets.prototype = Object.create(Phaser.Group.prototype)
Weapon.Rockets::constructor = Weapon.Rockets

Weapon.Rockets::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 10
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, -700
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 700
  @nextFire = @game.time.time + @fireRate
  return

#//////////////////////////////////////////////////////////////////////
#  A single bullet that scales in size as it moves across the screen //
#//////////////////////////////////////////////////////////////////////

Weapon.ScaleBullet = (game) ->
  Phaser.Group.call this, game, game.world, 'Scale Bullet', false, true, Phaser.Physics.ARCADE
  @nextFire = 0
  @bulletSpeed = 800
  @fireRate = 100
  i = 0
  while i < 32
    @add new Bullet(game, 'bullet9'), true
    i++
  @setAll 'scaleSpeed', 0.05
  this

Weapon.ScaleBullet.prototype = Object.create(Phaser.Group.prototype)
Weapon.ScaleBullet::constructor = Weapon.ScaleBullet

Weapon.ScaleBullet::fire = (source) ->
  if @game.time.time < @nextFire
    return
  x = source.x + 10
  y = source.y + 10
  @getFirstExists(false).fire x, y, 0, @bulletSpeed, 0, 0
  @nextFire = @game.time.time + @fireRate
  return

#///////////////////////////////////////////
#  A Weapon Combo - Single Shot + Rockets //
#///////////////////////////////////////////

Weapon.Combo1 = (game) ->
  @name = 'Combo One'
  @weapon1 = new (Weapon.SingleBullet)(game)
  @weapon2 = new (Weapon.Rockets)(game)
  return

Weapon.Combo1::reset = ->
  @weapon1.visible = false
  @weapon1.callAll 'reset', null, 0, 0
  @weapon1.setAll 'exists', false
  @weapon2.visible = false
  @weapon2.callAll 'reset', null, 0, 0
  @weapon2.setAll 'exists', false
  return

Weapon.Combo1::fire = (source) ->
  @weapon1.fire source
  @weapon2.fire source
  return

#///////////////////////////////////////////////////
#  A Weapon Combo - ThreeWay, Pattern and Rockets //
#///////////////////////////////////////////////////

Weapon.Combo2 = (game) ->
  @name = 'Combo Two'
  @weapon1 = new (Weapon.Pattern)(game)
  @weapon2 = new (Weapon.ThreeWay)(game)
  @weapon3 = new (Weapon.Rockets)(game)
  return

Weapon.Combo2::reset = ->
  @weapon1.visible = false
  @weapon1.callAll 'reset', null, 0, 0
  @weapon1.setAll 'exists', false
  @weapon2.visible = false
  @weapon2.callAll 'reset', null, 0, 0
  @weapon2.setAll 'exists', false
  @weapon3.visible = false
  @weapon3.callAll 'reset', null, 0, 0
  @weapon3.setAll 'exists', false
  return

Weapon.Combo2::fire = (source) ->
  @weapon1.fire source
  @weapon2.fire source
  @weapon3.fire source
  return

#  The core game loop

PhaserGame = ->
  @background = null
  @foreground = null
  @player = null
  @cursors = null
  @speed = 300
  @weapons = []
  @currentWeapon = 0
  @weaponName = null
  return

PhaserGame.prototype =
  init: ->
    @game.renderer.renderSession.roundPixels = true
    @physics.startSystem Phaser.Physics.ARCADE
    return
  preload: ->
    #  We need this because the assets are on Amazon S3
    #  Remove the next 2 lines if running locally
    @load.baseURL = 'http://files.phaser.io.s3.amazonaws.com/codingtips/issue007/'
    @load.crossOrigin = 'anonymous'
    @load.image 'background', 'assets/back.png'
    @load.image 'foreground', 'assets/fore.png'
    @load.image 'player', 'assets/ship.png'
    @load.bitmapFont 'shmupfont', 'assets/shmupfont.png', 'assets/shmupfont.xml'
    i = 1
    while i <= 11
      @load.image 'bullet' + i, 'assets/bullet' + i + '.png'
      i++
    #  Note: Graphics are not for use in any commercial project
    return
  create: ->
    @background = @add.tileSprite(0, 0, @game.width, @game.height, 'background')
    @background.autoScroll -40, 0
    @weapons.push new (Weapon.SingleBullet)(@game)
    @weapons.push new (Weapon.FrontAndBack)(@game)
    @weapons.push new (Weapon.ThreeWay)(@game)
    @weapons.push new (Weapon.EightWay)(@game)
    @weapons.push new (Weapon.ScatterShot)(@game)
    @weapons.push new (Weapon.Beam)(@game)
    @weapons.push new (Weapon.SplitShot)(@game)
    @weapons.push new (Weapon.Pattern)(@game)
    @weapons.push new (Weapon.Rockets)(@game)
    @weapons.push new (Weapon.ScaleBullet)(@game)
    @weapons.push new (Weapon.Combo1)(@game)
    @weapons.push new (Weapon.Combo2)(@game)
    @currentWeapon = 0
    i = 1
    while i < @weapons.length
      @weapons[i].visible = false
      i++
    @player = @add.sprite(64, 200, 'player')
    @physics.arcade.enable @player
    @player.body.collideWorldBounds = true
    @foreground = @add.tileSprite(0, 0, @game.width, @game.height, 'foreground')
    @foreground.autoScroll -60, 0
    @weaponName = @add.bitmapText(8, 364, 'shmupfont', 'ENTER = Next Weapon', 24)
    #  Cursor keys to fly + space to fire
    @cursors = @input.keyboard.createCursorKeys()
    @input.keyboard.addKeyCapture [ Phaser.Keyboard.SPACEBAR ]
    changeKey = @input.keyboard.addKey(Phaser.Keyboard.ENTER)
    changeKey.onDown.add @nextWeapon, this
    return
  nextWeapon: ->
    #  Tidy-up the current weapon
    if @currentWeapon > 9
      @weapons[@currentWeapon].reset()
    else
      @weapons[@currentWeapon].visible = false
      @weapons[@currentWeapon].callAll 'reset', null, 0, 0
      @weapons[@currentWeapon].setAll 'exists', false
    #  Activate the new one
    @currentWeapon++
    if @currentWeapon == @weapons.length
      @currentWeapon = 0
    @weapons[@currentWeapon].visible = true
    @weaponName.text = @weapons[@currentWeapon].name
    return
  update: ->
    @player.body.velocity.set 0
    if @cursors.left.isDown
      @player.body.velocity.x = -@speed
    else if @cursors.right.isDown
      @player.body.velocity.x = @speed
    if @cursors.up.isDown
      @player.body.velocity.y = -@speed
    else if @cursors.down.isDown
      @player.body.velocity.y = @speed
    if @input.keyboard.isDown(Phaser.Keyboard.SPACEBAR)
      @weapons[@currentWeapon].fire @player
    return
#game.state.add 'Game', PhaserGame, true

# ---
# generated by js2coffee 2.2.0

#module.exports =
class Drs
  constructor: (args)->
    for init, i in inits
      name = Object.keys(inits[i])
      @[name] = init[name]
    @initGame()

  initGame: ->
    @gameWidth = 256#(Math.min(1080, window.innerWidth-1))*0.6944444444444444
    @gameHeight = 256#(Math.min(1920, window.innerHeight-1))*0.2708333333333333
    @game = new (Phaser.Game)(
      @gameWidth, @gameHeight
      Phaser.AUTO
      @
      {
        preload: @.preload
        create: @.create
        update: @.update
        render: @.render
      }
    )
  getScaling: ()->
    Math.min(window.innerWidth, window.innerHeight)/@gameWidth


fire =
  fire: ()->
    weapon = @getActiveWeapon()
    if @game.time.now > @nextFire && weapon.countDead() > 0
      @nextFire = @game.time.now + weapon.fireRate
      bullet = weapon.getFirstDead()
      bullet.reset(@player.x, @player.y)
      bullet.rotation = @player.rotation-Math.PI/2
      @game.physics.arcade.velocityFromRotation(
        Math.PI/2+@player.rotation, 400, bullet.body.velocity
      )

createWeapon = ->
  group = drs.game.add.group()
  group.enableBody = true
  group.physicsBodyType = Phaser.Physics.ARCADE

  group.createMultiple(150, 'bullet')
  group.setAll('checkWorldBounds', true)
  group.setAll('outOfBoundsKill', true)
  group.setAll('anchor.x', 0.5)
  group.setAll('anchor.y', 0.5)

  group.fireRate = 80
  group.power = 50
  group.level = 0
  group.image = 'bullet'
  group.onHit = -> false
  group.onLevelUp = -> false
  group

createWeapons = createWeapons: ->
  @nextFire = 0
  @selectedWeapon = 0
  @getActiveWeapon = ->
    @weapons.getChildAt @selectedWeapon
  @weapons = drs.game.add.group()
  @weapons.enableBody = true
  @weapons.physicsBodyType = Phaser.Physics.ARCADE

  @weapons.add createWeapon()
  @weapons.add createWeapon()
  @weapons.add createWeapon()

Weapon.SingleBullet = (game) ->


(if !inits? then inits = [] else inits).push(
  fire, Weapon, createWeapons
)

(if !inits? then inits = [] else inits).push
  preload: ->
    @load.spritesheet 'player', 'assets/player.png', 16, 16
    @load.spritesheet 'enemys', 'assets/enemys.png', 16, 16
    @load.image 'bullet', 'assets/bullet.png'
    @load.image 'pixel', 'assets/1green_pixel.png'

(if !inits? then inits = [] else inits).push
  render: ->
    null

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

window.inits = []
window.c = console; c.l = c.log

window.onload = ->
  @drs = new Drs

#document.addEventListener 'deviceready', window.onload, false
