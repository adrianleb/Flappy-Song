describe 'pipes', () ->

  pipe = {}

  beforeEach () ->
    pipe = new Pipe(15, 15, 2, 4)

  it 'is movable with speed 1', () ->
    pipe.move(15)
    expect(pipe.x).toBe(0)

  it 'calculate hits', () ->
    expect(pipe.hit(mockHittable(2, 0, 3, 0))).toBe(false)
    expect(pipe.hit(mockHittable(13, 11, 15, 13))).toBe(true)
    expect(pipe.hit(mockHittable(13, 14, 15, 16))).toBe(false)

  mockHittable = (x, y, right, top) ->
    return {
      getX: -> x
      getY: -> y
      rightBound: -> right
      lowerPipeTop: -> top
    }
