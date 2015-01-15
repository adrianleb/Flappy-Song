class Pipe extends Movable
  constructor: (@x, @center, @width, @space, @worldHeight, @gameEl) ->
    lowerPipeHeight = @worldHeight - (@center + @space / 2)
   

    tmpl = "<div class='drawed-objects pipe' style='left:#{@x}px;'>
          <div class='pipe-upper' style='top: 0; height:#{@center - @space / 2}px;'></div>
          <div class='pipe-lower' style='top: #{@center + @space / 2}px; height:#{lowerPipeHeight};'></div>
        </div>"



    @pipeEl = $(tmpl).appendTo(@gameEl)[0]



  hit: (object) ->
    return false if object.getX() > @rightBound() && object.rightBound() > @rightBound()
    return false if object.getX() < @x && object.rightBound() < @x
    return false if object.getY() > @lowerBound() && object.upperBound() < @upperBound()

    true

  topPipeHeight: -> @center - @space / 2


  upperBound: -> @center + @space / 2

  rightBound: -> @x + @width

  move: (offset) ->

    @x = @x + offset
    @pipeEl.style.left = "#{@x}px"



class PipeFactory
  constructor: (@width, @space) ->
  getPipe: (x, center) ->
    new Pipe(x, center, @width, @space)
