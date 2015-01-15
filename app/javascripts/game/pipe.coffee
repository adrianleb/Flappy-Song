class Pipe
  constructor: (@movable, @center, @width, @space) ->

  move: (dX) ->
    @movable.move(dX)

  hit: (object) ->
    return false if object.getX() > @rightBound && object.rightBound() > @rightBound
    return false if object.getX() < @movable.x && object.rightBound() < @movable.x
    return false if object.getY() > @lowerBound() && object.upperBound() < @upperBound()

    true

  lowerBound: -> @center - @space / 2
  upperBound: -> @center + @space / 2
  rightBound: -> @movable.x + @width
