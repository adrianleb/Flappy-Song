class Graphics
  constructor: (@birdEl) ->
  renderBird: (bird) ->
    translateY = -1 * bird.getY()
    @birdEl.style.transform = "translateY(#{translateY}px)"
