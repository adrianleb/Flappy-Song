class Bird
  constructor: (@x, @y, @width, @height, @birdEl, @gravity) ->
    @speed = 0
  fall: () ->
    @y = Math.max(@y - @speed, 0)
    console.log @speed, @y, "falling"

  setSpeed: (@speed) ->
  getX: -> @x
  getY: -> @y
  rightBound: -> @x + @width
  upperBound: -> @y + @height
  getSpeed: -> @speed


  update: (worldHeight) ->
    console.log @speed, @y


    @speed = @speed + @gravity
    # unless @upperBound() <= ( (worldHeight  - 66) * -1) 
    @y = Math.max(@y + @speed, -1 * worldHeight + 40)


    console.log @y

    if @y > 1 then @y = 0

    @birdEl.style.transform = "translateY(#{@y}px)"