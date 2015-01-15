class Game
  constructor: (
    @width,
    @height,
    @gravity,
    @speed,
    @pipeFactory,
    @bird,
    @graphics
  ) ->
    @pipes = []
    @gravity.add(@bird)

  addPipe: (percentage) ->
    @pipes.push(@pipeFactory.getPipe(
      Math.ceil(@width / 1.1),
      (@height / 2) * percentage
    ))

  tick: () ->
    for pipe in @pipes
      pipe.move(@speed)

    @gravity.tick()
    @bird.fall()
    @graphics.renderBird(@bird)
