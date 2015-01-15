describe 'Gravity system', () ->
  it 'Updates objects speed', () ->
    gravity = new Gravity(15)

    mockGravitable = {
      getSpeed: -> 15
      setSpeed: () ->
    }

    spyOn mockGravitable, 'setSpeed'

    gravity.add(mockGravitable)
    gravity.tick()
    expect(mockGravitable.setSpeed).toHaveBeenCalledWith(30)

