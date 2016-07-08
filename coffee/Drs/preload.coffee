(if !inits? then inits = [] else inits).push
  preload: ->
    @load.spritesheet 'player', 'assets/player.png', 16, 16
    @load.spritesheet 'enemys', 'assets/enemys.png', 16, 16
    @load.image 'bullet', 'assets/bullet.png'
    @load.image 'pixel', 'assets/1green_pixel.png'
