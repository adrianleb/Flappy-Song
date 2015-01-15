class Movable
  constructor: (@x, @speed) ->

  move: (dX) ->
    @x -= dX * @speed
