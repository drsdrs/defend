(function() {
  var Bullet, Drs, PhaserGame, Weapon, createWeapon, createWeapons, fire, inits;

  (typeof inits === "undefined" || inits === null ? inits = [] : inits).push({
    addAttacker: function(pos, type, lvl) {
      var angle, att, enemyType, j, ref, ref1, results;
      enemyType = type || this.game.rnd.pick([0, 1, 2, 3]);
      att = this.attackers.create(pos.x, pos.y, 'enemys', enemyType);
      att.enemyType = enemyType;
      att.animations.add('attack', (function() {
        results = [];
        for (var j = ref = enemyType * 4, ref1 = enemyType * 4 + 3; ref <= ref1 ? j <= ref1 : j >= ref1; ref <= ref1 ? j++ : j--){ results.push(j); }
        return results;
      }).apply(this), 7, true);
      att.animations.play('attack');
      this.game.physics.arcade.enable(att);
      att.smoothed = false;
      att.anchor.set(0.5);
      this.game.physics.arcade.moveToXY(att, this.gameWidth / 2, this.gameWidth / 2, this.game.rnd.between(10, 70));
      angle = Math.PI / 2 + Math.atan2(pos.y - this.gameWidth / 2, pos.x - this.gameWidth / 2);
      att.rotation = angle;
      return att.stats = {
        spd: 0,
        acc: 0,
        life: 100
      };
    }
  });

  (inits == null ? inits = [] : inits).push({
    create: function() {
      var i, j, results, that, trgPos, val0;
      that = this.game.parent;
      this.physics.startSystem(Phaser.Physics.ARCADE);
      this.stage.smoothed = false;
      this.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL;
      that.btnInput = this.input.keyboard.createCursorKeys();
      that.createPlayer();
      that.createWeapons();
      this.game.add.image(0, 0, 'pixel');
      that.emitter = this.game.add.emitter(this.game.world.centerX, this.game.world.centerY, 50);
      that.emitter.width = 0;
      that.emitter.gravity = 0;
      that.emitter.setAlpha(.2, 0.8);
      that.emitter.setScale(5, 6, 5, 6);
      that.emitter.setXSpeed(-600, 600);
      that.emitter.setYSpeed(-600, 600);
      that.emitter.makeParticles('pixel');
      that.attackers = this.add.group();
      that.attackers.enableBody = true;
      that.attackers.physicsBodyType = Phaser.Physics.arcade;
      results = [];
      for (i = j = 0; j <= 8; i = ++j) {
        val0 = Math.random() > .5 ? that.gameWidth + 16 : -16;
        trgPos = Math.random() > .5 ? {
          x: val0,
          y: Math.random() * that.gameWidth
        } : {
          x: Math.random() * that.gameWidth,
          y: val0
        };
        results.push(that.addAttacker(trgPos));
      }
      return results;
    }
  });

  (inits == null ? inits = [] : inits).push({
    createBullet: function() {
      this.bullets = this.game.add.group();
      this.bullets.enableBody = true;
      this.bullets.physicsBodyType = Phaser.Physics.ARCADE;
      this.bullets.createMultiple(50, 'bullet');
      this.bullets.setAll('checkWorldBounds', true);
      this.bullets.setAll('outOfBoundsKill', true);
      this.bullets.setAll('anchor.x', 0.5);
      return this.bullets.setAll('anchor.y', 0.5);
    }
  });

  (inits == null ? inits = [] : inits).push({
    createPlayer: function() {
      this.player = this.game.add.sprite(this.gameWidth / 2, this.gameWidth / 2, 'player', 0);
      this.player.anchor.set(0.5);
      this.player.enableBody = true;
      this.player.physicsBodyType = Phaser.Physics.arcade;
      this.game.physics.enable(this.player, Phaser.Physics.ARCADE);
      this.player.body.immovable = true;
      return this.player.stats = {
        rotationSpeed: 20
      };
    }
  });

  Bullet = function(game, key) {
    Phaser.Sprite.call(this, game, 0, 0, key);
    this.texture.baseTexture.scaleMode = PIXI.scaleModes.NEAREST;
    this.anchor.set(0.5);
    this.checkWorldBounds = true;
    this.outOfBoundsKill = true;
    this.exists = false;
    this.tracking = false;
    this.scaleSpeed = 0;
  };

  Bullet.prototype = Object.create(Phaser.Sprite.prototype);

  Bullet.prototype.constructor = Bullet;

  Bullet.prototype.fire = function(x, y, angle, speed, gx, gy) {
    gx = gx || 0;
    gy = gy || 0;
    this.reset(x, y);
    this.scale.set(1);
    this.game.physics.arcade.velocityFromAngle(angle, speed, this.body.velocity);
    this.angle = angle;
    this.body.gravity.set(gx, gy);
  };

  Bullet.prototype.update = function() {
    if (this.tracking) {
      this.rotation = Math.atan2(this.body.velocity.y, this.body.velocity.x);
    }
    if (this.scaleSpeed > 0) {
      this.scale.x += this.scaleSpeed;
      this.scale.y += this.scaleSpeed;
    }
  };

  Weapon = {};

  Weapon.SingleBullet = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Single Bullet', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 600;
    this.fireRate = 100;
    i = 0;
    while (i < 64) {
      this.add(new Bullet(game, 'bullet5'), true);
      i++;
    }
    return this;
  };

  Weapon.SingleBullet.prototype = Object.create(Phaser.Group.prototype);

  Weapon.SingleBullet.prototype.constructor = Weapon.SingleBullet;

  Weapon.SingleBullet.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 10;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.FrontAndBack = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Front And Back', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 600;
    this.fireRate = 100;
    i = 0;
    while (i < 64) {
      this.add(new Bullet(game, 'bullet5'), true);
      i++;
    }
    return this;
  };

  Weapon.FrontAndBack.prototype = Object.create(Phaser.Group.prototype);

  Weapon.FrontAndBack.prototype.constructor = Weapon.FrontAndBack;

  Weapon.FrontAndBack.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 10;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 180, this.bulletSpeed, 0, 0);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.ThreeWay = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Three Way', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 600;
    this.fireRate = 100;
    i = 0;
    while (i < 96) {
      this.add(new Bullet(game, 'bullet7'), true);
      i++;
    }
    return this;
  };

  Weapon.ThreeWay.prototype = Object.create(Phaser.Group.prototype);

  Weapon.ThreeWay.prototype.constructor = Weapon.ThreeWay;

  Weapon.ThreeWay.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 10;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 270, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 90, this.bulletSpeed, 0, 0);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.EightWay = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Eight Way', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 600;
    this.fireRate = 100;
    i = 0;
    while (i < 96) {
      this.add(new Bullet(game, 'bullet5'), true);
      i++;
    }
    return this;
  };

  Weapon.EightWay.prototype = Object.create(Phaser.Group.prototype);

  Weapon.EightWay.prototype.constructor = Weapon.EightWay;

  Weapon.EightWay.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 16;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 45, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 90, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 135, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 180, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 225, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 270, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 315, this.bulletSpeed, 0, 0);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.ScatterShot = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Scatter Shot', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 600;
    this.fireRate = 40;
    i = 0;
    while (i < 32) {
      this.add(new Bullet(game, 'bullet5'), true);
      i++;
    }
    return this;
  };

  Weapon.ScatterShot.prototype = Object.create(Phaser.Group.prototype);

  Weapon.ScatterShot.prototype.constructor = Weapon.ScatterShot;

  Weapon.ScatterShot.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 16;
    y = source.y + source.height / 2 + this.game.rnd.between(-10, 10);
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.Beam = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Beam', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 1000;
    this.fireRate = 45;
    i = 0;
    while (i < 64) {
      this.add(new Bullet(game, 'bullet11'), true);
      i++;
    }
    return this;
  };

  Weapon.Beam.prototype = Object.create(Phaser.Group.prototype);

  Weapon.Beam.prototype.constructor = Weapon.Beam;

  Weapon.Beam.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 40;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.SplitShot = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Split Shot', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 700;
    this.fireRate = 40;
    i = 0;
    while (i < 64) {
      this.add(new Bullet(game, 'bullet8'), true);
      i++;
    }
    return this;
  };

  Weapon.SplitShot.prototype = Object.create(Phaser.Group.prototype);

  Weapon.SplitShot.prototype.constructor = Weapon.SplitShot;

  Weapon.SplitShot.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 20;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, -500);
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 500);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.Pattern = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Pattern', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 600;
    this.fireRate = 40;
    this.pattern = Phaser.ArrayUtils.numberArrayStep(-800, 800, 200);
    this.pattern = this.pattern.concat(Phaser.ArrayUtils.numberArrayStep(800, -800, -200));
    this.patternIndex = 0;
    i = 0;
    while (i < 64) {
      this.add(new Bullet(game, 'bullet4'), true);
      i++;
    }
    return this;
  };

  Weapon.Pattern.prototype = Object.create(Phaser.Group.prototype);

  Weapon.Pattern.prototype.constructor = Weapon.Pattern;

  Weapon.Pattern.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 20;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, this.pattern[this.patternIndex]);
    this.patternIndex++;
    if (this.patternIndex === this.pattern.length) {
      this.patternIndex = 0;
    }
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.Rockets = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Rockets', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 400;
    this.fireRate = 250;
    i = 0;
    while (i < 32) {
      this.add(new Bullet(game, 'bullet10'), true);
      i++;
    }
    this.setAll('tracking', true);
    return this;
  };

  Weapon.Rockets.prototype = Object.create(Phaser.Group.prototype);

  Weapon.Rockets.prototype.constructor = Weapon.Rockets;

  Weapon.Rockets.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 10;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, -700);
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 700);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.ScaleBullet = function(game) {
    var i;
    Phaser.Group.call(this, game, game.world, 'Scale Bullet', false, true, Phaser.Physics.ARCADE);
    this.nextFire = 0;
    this.bulletSpeed = 800;
    this.fireRate = 100;
    i = 0;
    while (i < 32) {
      this.add(new Bullet(game, 'bullet9'), true);
      i++;
    }
    this.setAll('scaleSpeed', 0.05);
    return this;
  };

  Weapon.ScaleBullet.prototype = Object.create(Phaser.Group.prototype);

  Weapon.ScaleBullet.prototype.constructor = Weapon.ScaleBullet;

  Weapon.ScaleBullet.prototype.fire = function(source) {
    var x, y;
    if (this.game.time.time < this.nextFire) {
      return;
    }
    x = source.x + 10;
    y = source.y + 10;
    this.getFirstExists(false).fire(x, y, 0, this.bulletSpeed, 0, 0);
    this.nextFire = this.game.time.time + this.fireRate;
  };

  Weapon.Combo1 = function(game) {
    this.name = 'Combo One';
    this.weapon1 = new Weapon.SingleBullet(game);
    this.weapon2 = new Weapon.Rockets(game);
  };

  Weapon.Combo1.prototype.reset = function() {
    this.weapon1.visible = false;
    this.weapon1.callAll('reset', null, 0, 0);
    this.weapon1.setAll('exists', false);
    this.weapon2.visible = false;
    this.weapon2.callAll('reset', null, 0, 0);
    this.weapon2.setAll('exists', false);
  };

  Weapon.Combo1.prototype.fire = function(source) {
    this.weapon1.fire(source);
    this.weapon2.fire(source);
  };

  Weapon.Combo2 = function(game) {
    this.name = 'Combo Two';
    this.weapon1 = new Weapon.Pattern(game);
    this.weapon2 = new Weapon.ThreeWay(game);
    this.weapon3 = new Weapon.Rockets(game);
  };

  Weapon.Combo2.prototype.reset = function() {
    this.weapon1.visible = false;
    this.weapon1.callAll('reset', null, 0, 0);
    this.weapon1.setAll('exists', false);
    this.weapon2.visible = false;
    this.weapon2.callAll('reset', null, 0, 0);
    this.weapon2.setAll('exists', false);
    this.weapon3.visible = false;
    this.weapon3.callAll('reset', null, 0, 0);
    this.weapon3.setAll('exists', false);
  };

  Weapon.Combo2.prototype.fire = function(source) {
    this.weapon1.fire(source);
    this.weapon2.fire(source);
    this.weapon3.fire(source);
  };

  PhaserGame = function() {
    this.background = null;
    this.foreground = null;
    this.player = null;
    this.cursors = null;
    this.speed = 300;
    this.weapons = [];
    this.currentWeapon = 0;
    this.weaponName = null;
  };

  PhaserGame.prototype = {
    init: function() {
      this.game.renderer.renderSession.roundPixels = true;
      this.physics.startSystem(Phaser.Physics.ARCADE);
    },
    preload: function() {
      var i;
      this.load.baseURL = 'http://files.phaser.io.s3.amazonaws.com/codingtips/issue007/';
      this.load.crossOrigin = 'anonymous';
      this.load.image('background', 'assets/back.png');
      this.load.image('foreground', 'assets/fore.png');
      this.load.image('player', 'assets/ship.png');
      this.load.bitmapFont('shmupfont', 'assets/shmupfont.png', 'assets/shmupfont.xml');
      i = 1;
      while (i <= 11) {
        this.load.image('bullet' + i, 'assets/bullet' + i + '.png');
        i++;
      }
    },
    create: function() {
      var changeKey, i;
      this.background = this.add.tileSprite(0, 0, this.game.width, this.game.height, 'background');
      this.background.autoScroll(-40, 0);
      this.weapons.push(new Weapon.SingleBullet(this.game));
      this.weapons.push(new Weapon.FrontAndBack(this.game));
      this.weapons.push(new Weapon.ThreeWay(this.game));
      this.weapons.push(new Weapon.EightWay(this.game));
      this.weapons.push(new Weapon.ScatterShot(this.game));
      this.weapons.push(new Weapon.Beam(this.game));
      this.weapons.push(new Weapon.SplitShot(this.game));
      this.weapons.push(new Weapon.Pattern(this.game));
      this.weapons.push(new Weapon.Rockets(this.game));
      this.weapons.push(new Weapon.ScaleBullet(this.game));
      this.weapons.push(new Weapon.Combo1(this.game));
      this.weapons.push(new Weapon.Combo2(this.game));
      this.currentWeapon = 0;
      i = 1;
      while (i < this.weapons.length) {
        this.weapons[i].visible = false;
        i++;
      }
      this.player = this.add.sprite(64, 200, 'player');
      this.physics.arcade.enable(this.player);
      this.player.body.collideWorldBounds = true;
      this.foreground = this.add.tileSprite(0, 0, this.game.width, this.game.height, 'foreground');
      this.foreground.autoScroll(-60, 0);
      this.weaponName = this.add.bitmapText(8, 364, 'shmupfont', 'ENTER = Next Weapon', 24);
      this.cursors = this.input.keyboard.createCursorKeys();
      this.input.keyboard.addKeyCapture([Phaser.Keyboard.SPACEBAR]);
      changeKey = this.input.keyboard.addKey(Phaser.Keyboard.ENTER);
      changeKey.onDown.add(this.nextWeapon, this);
    },
    nextWeapon: function() {
      if (this.currentWeapon > 9) {
        this.weapons[this.currentWeapon].reset();
      } else {
        this.weapons[this.currentWeapon].visible = false;
        this.weapons[this.currentWeapon].callAll('reset', null, 0, 0);
        this.weapons[this.currentWeapon].setAll('exists', false);
      }
      this.currentWeapon++;
      if (this.currentWeapon === this.weapons.length) {
        this.currentWeapon = 0;
      }
      this.weapons[this.currentWeapon].visible = true;
      this.weaponName.text = this.weapons[this.currentWeapon].name;
    },
    update: function() {
      this.player.body.velocity.set(0);
      if (this.cursors.left.isDown) {
        this.player.body.velocity.x = -this.speed;
      } else if (this.cursors.right.isDown) {
        this.player.body.velocity.x = this.speed;
      }
      if (this.cursors.up.isDown) {
        this.player.body.velocity.y = -this.speed;
      } else if (this.cursors.down.isDown) {
        this.player.body.velocity.y = this.speed;
      }
      if (this.input.keyboard.isDown(Phaser.Keyboard.SPACEBAR)) {
        this.weapons[this.currentWeapon].fire(this.player);
      }
    }
  };

  Drs = (function() {
    function Drs(args) {
      var i, init, j, len, name;
      for (i = j = 0, len = inits.length; j < len; i = ++j) {
        init = inits[i];
        name = Object.keys(inits[i]);
        this[name] = init[name];
      }
      this.initGame();
    }

    Drs.prototype.initGame = function() {
      return this.game = new Phaser.Game(512, 512, Phaser.AUTO, this, {
        preload: this.preload,
        create: this.create,
        update: this.update,
        render: this.render
      });
    };

    Drs.prototype.gameWidth = 512;

    Drs.prototype.gameHeight = 512;

    Drs.prototype.getScaling = function() {
      return Math.min(window.innerWidth, window.innerHeight) / this.gameWidth;
    };

    return Drs;

  })();

  fire = {
    fire: function() {
      var bullet, weapon;
      weapon = this.getActiveWeapon();
      if (this.game.time.now > this.nextFire && weapon.countDead() > 0) {
        this.nextFire = this.game.time.now + weapon.fireRate;
        bullet = weapon.getFirstDead();
        bullet.reset(this.player.x, this.player.y);
        bullet.rotation = this.player.rotation - Math.PI / 2;
        return this.game.physics.arcade.velocityFromRotation(Math.PI / 2 + this.player.rotation, 400, bullet.body.velocity);
      }
    }
  };

  createWeapon = function() {
    var group;
    group = drs.game.add.group();
    group.enableBody = true;
    group.physicsBodyType = Phaser.Physics.ARCADE;
    group.createMultiple(150, 'bullet');
    group.setAll('checkWorldBounds', true);
    group.setAll('outOfBoundsKill', true);
    group.setAll('anchor.x', 0.5);
    group.setAll('anchor.y', 0.5);
    group.fireRate = 80;
    group.power = 50;
    group.level = 0;
    group.image = 'bullet';
    group.onHit = function() {
      return false;
    };
    group.onLevelUp = function() {
      return false;
    };
    return group;
  };

  createWeapons = {
    createWeapons: function() {
      this.nextFire = 0;
      this.selectedWeapon = 0;
      this.getActiveWeapon = function() {
        return this.weapons.getChildAt(this.selectedWeapon);
      };
      this.weapons = drs.game.add.group();
      this.weapons.enableBody = true;
      this.weapons.physicsBodyType = Phaser.Physics.ARCADE;
      this.weapons.add(createWeapon());
      this.weapons.add(createWeapon());
      return this.weapons.add(createWeapon());
    }
  };

  Weapon.SingleBullet = function(game) {};

  (inits == null ? inits = [] : inits).push(fire, Weapon, createWeapons);

  (inits == null ? inits = [] : inits).push({
    preload: function() {
      this.load.spritesheet('player', 'assets/player.png', 16, 16);
      this.load.spritesheet('enemys', 'assets/enemys.png', 16, 16);
      this.load.image('bullet', 'assets/bullet.png');
      return this.load.image('pixel', 'assets/1green_pixel.png');
    }
  });

  (inits == null ? inits = [] : inits).push({
    render: function() {
      return null;
    }
  });

  (inits == null ? inits = [] : inits).push({
    update: function() {
      var that;
      that = this.game.parent;
      this.physics.arcade.collide(that.attackers, that.player, that.enemyHitPlayer);
      this.physics.arcade.collide(that.weapons, that.attackers, that.bulletHitEnemy);
      return that.playerBrainThink();
    }
  });

  inits.push({
    playerBrainLevel: 1
  });

  inits.push({
    playerBrainThink: function() {
      return this.playerBrain(this.playerBrainLevel);
    }
  });

  inits.push({
    playerBrain: function(brainLvl) {
      var angle, rot;
      if (brainLvl === 0) {
        this.player.body.angularVelocity = Math.sin(this.game.time.time / 1000) * 250;
        return this.fire();
      } else if (brainLvl === 1) {
        if (this.player.enemyToAttack == null) {
          this.player.enemyToAttack = this.attackers.getClosestTo(this.player);
          angle = this.game.physics.arcade.angleBetween(this.player.enemyToAttack, this.player);
          this.player.rotationTarget = Math.PI / 2 + angle;
          return this.player.body.angularVelocity = 200;
        } else {
          rot = (this.player.rotationTarget - this.player.rotation) * 50;
          if (!this.player.enemyToAttack.alive) {
            return this.player.enemyToAttack = null;
          } else {
            return this.fire();
          }
        }
      }
    }
  });

  inits.push({
    bulletHitEnemy: function(bullet, target) {
      var angle, that, trgPos, val0;
      that = drs;
      bullet.kill();
      target.stats.life -= bullet.parent.power;
      that.emitter.x = target.x;
      that.emitter.y = target.y;
      if (target.stats.life <= 0) {
        target.kill();
        that.player.enemyToAttack = null;
        val0 = Math.random() > .5 ? that.gameWidth + 16 : -16;
        trgPos = Math.random() > .5 ? {
          x: val0,
          y: Math.random() * that.gameWidth
        } : {
          x: Math.random() * that.gameWidth,
          y: val0
        };
        that.addAttacker(trgPos);
        return that.emitter.explode(500, 25);
      } else {
        that.emitter.explode(80, 3);
        that.game.physics.arcade.moveToXY(target, that.gameWidth / 2, that.gameWidth / 2, that.game.rnd.between(10, 70));
        angle = Math.PI / 2 + Math.atan2(target.y - that.gameWidth / 2, target.x - that.gameWidth / 2);
        return target.rotation = angle;
      }
    }
  });

  inits.push({
    enemyHitPlayer: function(enemy, player) {
      return console.log('ouch');
    }
  });

  window.inits = [];

  window.c = console;

  c.l = c.log;

  window.onload = function() {
    return this.drs = new Drs;
  };

}).call(this);

//# sourceMappingURL=main.js.map
