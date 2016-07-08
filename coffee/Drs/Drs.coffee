#module.exports =
class Drs
  constructor: (args)->
    for init, i in inits
      name = Object.keys(inits[i])
      @[name] = init[name]
    @initGame()

  initGame: ->
    @game = new (Phaser.Game)(
      512, 512
      Phaser.AUTO
      @
      {
        preload: @.preload
        create: @.create
        update: @.update
        render: @.render
      }
    )
  gameWidth: 512
  gameHeight: 512
  getScaling: ()->
    Math.min(window.innerWidth, window.innerHeight)/@gameWidth
