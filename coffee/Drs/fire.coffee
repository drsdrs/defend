
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
