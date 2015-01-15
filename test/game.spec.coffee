describe 'Game system', () ->

  game = {}
  gravity = new Gravity(20)
  factory = new PipeFactory(20, 20)
  width = 110
  height = 100
  bird = new Bird(width / 2, height / 2, 34, 24)


  beforeEach () ->
    game = new Game(width, height, gravity, 20, factory, bird)


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

  it 'ticks gravity and bird every tick', () ->
    spyOn(gravity, 'tick')
    spyOn(bird, 'fall')
    game.tick()
    expect(gravity.tick).toHaveBeenCalled()
    expect(bird.fall).toHaveBeenCalled()
