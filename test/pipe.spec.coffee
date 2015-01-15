describe 'pipes', () ->

  pipe = {}
  movable = {}

  beforeEach () ->
    movable = new Movable(15, 1)
    pipe = new Pipe(movable, 15, 2, 4)

  it 'moves', () ->
    spyMovable = spyOn(movable, 'move')
    pipe.move(15)
    expect(spyMovable).toHaveBeenCalledWith(15)

  mockHittable = (x, y, right, top) ->
    return {
      getX: -> x
      getY: -> y
      rightBound: -> right
      upperBound: -> top
    }

  it 'calculate hits', () ->
    expect(pipe.hit(mockHittable(2, 0, 3, 0))).toBe(false)
    expect(pipe.hit(mockHittable(13, 11, 15, 13))).toBe(true)
    expect(pipe.hit(mockHittable(13, 14, 15, 16))).toBe(false)
