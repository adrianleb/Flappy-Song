class Movable
  constructor: (@x, @y, @speed) ->

  move: (dX) ->
    @x -= dX * @speed
