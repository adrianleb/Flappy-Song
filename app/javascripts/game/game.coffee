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
    @ticks = 0

  jump: () ->
    @bird.setSpeed(-20)

  addPipe: (percentage) ->
    @pipes.push(@pipeFactory.getPipe(
      Math.ceil(@width / 1.1),
      (@height / 2) * percentage
    ))

  tick: () ->
    for pipe in @pipes
      pipe.move(@speed)

    if (@ticks % 10 == 0)
      @gravity.tick()
      @bird.fall()

    @ticks++
    @graphics.renderBird(@bird)
