class Gravity
  constructor: (@gravity) ->
    @gravitables = []

  add: (gravitable) ->
    @gravitables.push(gravitable)

  tick: () ->
    for gravitable in @gravitables
      gravitable.setSpeed(gravitable.getSpeed() + @gravity)
