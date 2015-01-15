class Graphics
  constructor: (@birdEl) ->

  renderBird: (bird, screenHeight) ->
    halfScreen = screenHeight / 2
    translateY = bird.getY() - halfScreen
    @birdEl.css({'transform': 'translate(0, ' + translateY + ')'})
