class Pipe extends Movable
  constructor: (@x, @center, @width, @space) ->
    super(@x, 1)

  hit: (object) ->
    return false if object.getX() > @rightBound() && object.rightBound() > @rightBound()
    return false if object.getX() < @x && object.rightBound() < @x
    return false if object.getY() > @lowerBound() && object.upperBound() < @upperBound()

    true

  lowerBound: -> @center - @space / 2
  upperBound: -> @center + @space / 2
  rightBound: -> @x + @width


class PipeFactory
  constructor: (@width, @space) ->
  getPipe: (x, center) ->
    new Pipe(x, center, @width, @space)
