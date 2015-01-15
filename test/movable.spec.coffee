it 'moves depending on its speed', () ->
  speed1 = new Movable(15, 0, 1)
  speed2 = new Movable(15, 0, 2)
  speedHalf = new Movable(15, 0, .5)

  speed1.move(15)
  speed2.move(15)
  speedHalf.move(15)

  expect(speed1.x).toBe(0)
  expect(speed2.x).toBe(-15)
  expect(speedHalf.x).toBe(7.5)
