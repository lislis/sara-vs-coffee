require ('gosu')

class GameWindow < Gosu::Window
  def initialize
    super 960, 640
    self.caption = 'Sara vs Coffee'

    @player = Player.new
    @player.warp(300, 300)

    @barista = Barista.new
    @barista.warp(720, 40)

    @counter = Counter.new
    @computer = Computer.new

    @font = Gosu::Font.new(20)
  end

  def update

    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @player.move_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.move_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      @player.move_up
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpButton1 then
      @player.move_down
    end

    @barista.moving
  end

  def draw
    @counter.draw
    @player.draw
    @barista.draw
    @computer.draw
    @font.draw("Coffees consumed: #{@player.cups}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_fff00)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

class Player

  attr_reader :cups

  def initialize
   @image = Gosu::Image.new('assets/player.png')
   @x = @y = 0
   @caffeine = 0
   @money = 0
   @speed = 2

   @caffeine_min = 0
   @caffeine_max = 100

   @cups = 0
   @cups_goal = 100
  end

  def cups
    @cups
  end
  
  def warp(x, y)
    @x, @y = x, y
  end

  def move_left
    @x = @x - @speed
  end

  def move_right
    @x = @x + @speed
  end

  def move_up
    @y = @y - @speed
  end

  def move_down
    @y = @y + @speed
  end

  def draw
    @image.draw(@x, @y, ZOrder::Player)
  end

end

module ZOrder
  Background, Barista, Player, UI = *0..3
end

class Barista

  attr_accessor :is_preping, :bribe_level

  def initialize
    @image = Gosu::Image.new('assets/player.png')
    @prep_time = 4
    @is_preping = false
    @is_talking = false
    @bribe_level = 0

    @y_min = 20
    @y_max = 550
    @x = @y = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def moving
    if !@is_talking then
      
    end
  end

  def draw
    @image.draw(@x, @y, ZOrder::Barista)
  end
end

class Counter

  def initialize
    @image = Gosu::Image.new('assets/counter.png')
  end

  def draw
    @image.draw(680, 0, ZOrder::Background)
  end
end

class Computer

  def initialize
    @image = Gosu::Image.new('assets/player.png')
    @is_visible = true
    @x = @y = 0
  end

  def randNum
    0..600.to_a.sample
  end

  def randPos
    @x, @y = randNum, randNum
  end

  def toggleVisibility
    @is_visible = !!@is_visible
  end

  def draw
    if @is_visible then
      @image.draw(@x, @y, ZOrder::Barista)
    end
  end

end

window = GameWindow.new
window.show
