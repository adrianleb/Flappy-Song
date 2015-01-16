class Bird
  constructor: (@x, @y, @width, @height, @birdEl, @gravity) ->
    @speed = 0
    @birdEl.style.left = "#{@x}px"
  fall: () ->
    @y = Math.max(@y - @speed, 0)
    console.log @speed, @y, "falling"

  setSpeed: (@speed) ->
  getX: -> @x
  getY: -> @y
  rightBound: -> @x + @width
  lowerBound: -> @y + @height
  getSpeed: -> @speed


  update: (worldHeight) ->
    @speed = @speed + @gravity
    @y = Math.max(@y + @speed, -1 * worldHeight + 40)
    @y = Math.min(@y, worldHeight)


    # if @y > 1 then @y = 1
    @birdEl.style.transform = "translateY(#{@y}px)"