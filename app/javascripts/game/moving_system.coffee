class MovingSystem
  constructor: (speed, movables) ->
    @speed = speed
    @movables = movables
  tick: ->
    for movable in @movables
      movable.move(@speed)
