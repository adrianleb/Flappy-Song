class Pipe extends Movable
  constructor: (@x, @center, @width, @space, @worldHeight, @gameEl) ->
    # @x = @x - @width / 2
    lowerPipeHeight = @worldHeight - (@center + @space / 2)
   

    tmpl = "<div class='drawed-objects pipe' style='transform: translateX(#{@x}px);'>
          <div class='pipe-upper' style='top: 0; height:#{@center - @space / 2}px;'></div>
          <div class='pipe-lower' style='top: #{@center + @space / 2}px; height:#{lowerPipeHeight};'></div>
        </div>"


    @pipeEl = $(tmpl).appendTo(@gameEl)[0]



  hit: (object) ->


    birdTop = parseInt(object.y)
    birdBottom = parseInt(object.lowerBound())


    birdLeftSide = object.x
    birdRightSide = object.rightBound()



    # console.log(birdRightSide, @x, @rightBound(), birdLeftSide)


    if birdRightSide in [parseInt(@x)...parseInt(@rightBound())] or birdLeftSide in [parseInt(@x)...parseInt(@rightBound())]
      console.log 'bird is horizontally colliding'


      console.log(birdTop, parseInt(@topPipeHeight()), parseInt(@upperBound()), birdBottom)
      console.log(birdTop in [parseInt(@topPipeHeight())...parseInt(@upperBound())])
      console.log(birdBottom in [parseInt(@topPipeHeight())...parseInt(@upperBound())])

      unless birdTop in [parseInt(@topPipeHeight())...parseInt(@upperBound())] or birdBottom in [parseInt(@topPipeHeight())...parseInt(@upperBound())]
        console.log "bird collided horizontally and vertically!"
        return true

      # else
        # addscore

    return false


    # # check if right side of bird touches left side of pipe

    # # return false if 

    # # console.log("test 1: ", (object.getX() > @rightBound() && object.rightBound() > @rightBound()))
    # return false if object.getX() > @rightBound() && object.rightBound() > @rightBound()

    # console.log("test 2: ", (object.getX() < @x && object.rightBound() < @x))

    # return false if object.getX() < @x && object.rightBound() < @x

    # console.log("test 3: ", (object.getY() > @topPipeHeight() && object.upperBound() < @upperBound()))

    # return false if object.getY() > @topPipeHeight() && object.upperBound() < @upperBound()


    # true

  topPipeHeight: -> @center - @space / 2


  upperBound: -> @center + @space / 2

  rightBound: -> @x + @width

  move: (offset) ->

    @x = @x + offset
    @pipeEl.style.transform = "translateX(#{@x}px)"
    # @pipeEl.style.left = "#{@x}px"



class PipeFactory
  constructor: (@width, @space) ->
  getPipe: (x, center) ->
    new Pipe(x, center, @width, @space)
