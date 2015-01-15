it 'moves by given speed every tick', () ->

  fakeMovable = jasmine.createSpyObj('fakeMovable', ['move'])
  movables = [fakeMovable]
  movingSystem = new MovingSystem(15, movables)
  movingSystem.tick()
  expect(fakeMovable.move).toHaveBeenCalledWith(15)
