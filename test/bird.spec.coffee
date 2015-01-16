describe 'Flappy bird', () ->

  bird = {}

  beforeEach () ->
    bird = new Bird(0, 15, 10, 15)

  it 'is affected by gravity', () ->
    bird.fall()
    expect(bird.getSpeed()).toBe(0)
    expect(bird.y).toBe(15)

    bird.setSpeed(15)
    bird.fall()
    expect(bird.y).toBe(0)

  it 'does not fall lower than 0', () ->
    bird.setSpeed 30
    bird.fall()
    expect(bird.y).toBe(0)

  it 'has a hitbox', () ->
    expect(bird.getX()).toBe(0)
    expect(bird.getY()).toBe(15)
    expect(bird.rightBound()).toBe(10)
    expect(bird.lowerPipeTop()).toBe(30)
