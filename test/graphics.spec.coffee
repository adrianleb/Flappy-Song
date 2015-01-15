#describe 'Graphics system', () ->
#  it 'applies correct transformation to bird element', () ->
#    birdEl = jasmine.createSpyObj('birdEl', ['css'])
#    graphics = new Graphics(birdEl)
#
#    graphics.renderBird(new Bird(50, 50, 10, 10), 100)
#    expect(birdEl.css).toHaveBeenCalledWith({'transform': 'translate(0, 0px)'})
#
#    graphics.renderBird(new Bird(50, 70, 10, 10), 100)
#    expect(birdEl.css).toHaveBeenCalledWith({'transform': 'translate(0, 20px)'})
