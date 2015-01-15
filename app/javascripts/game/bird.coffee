class Bird
  constructor: (@x, @y, @width, @height) ->
    @speed = 0
  fall: () ->
    @y = Math.max(@y - @speed, 0)
  setSpeed: (@speed) ->
  getX: -> @x
  getY: -> @y
  rightBound: -> @x + @width
  upperBound: -> @y + @height
  getSpeed: -> @speed
