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
