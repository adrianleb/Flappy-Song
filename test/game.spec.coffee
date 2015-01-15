describe 'Game system', () ->

  game = {}
  gravity = new Gravity(20)
  factory = new PipeFactory(20, 20)

  beforeEach () ->
    game = new Game(110, 100, gravity, 20, factory)


  it 'adds pipes in the correct position', () ->

    spyOn(factory, 'getPipe').and.callThrough()
    game.addPipe(.5)
    expect(factory.getPipe).toHaveBeenCalledWith(100, 25)

  it 'moves pipes every tick', () ->
    game.addPipe(.5)
    pipe = game.pipes[0]
    spyOn(pipe, 'move')
    game.tick()
    expect(pipe.move).toHaveBeenCalledWith(20)
