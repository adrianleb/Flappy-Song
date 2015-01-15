class Game
  constructor: (
    @width,
    @height,
    @gravity,
    @speed,
    @pipeFactory
  ) ->
    @pipes = []

  addPipe: (percentage) ->
    @pipes.push(@pipeFactory.getPipe(
      Math.ceil(@width / 1.1),
      (@height / 2) * percentage
    ))

  tick: () ->
    for pipe in @pipes
      pipe.move(@speed)
