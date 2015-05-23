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
    @coffee = Coffee.new

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

    @player.update(@barista, @computer)
    @computer.update
    @barista.update
  end

  def draw
    @counter.draw
    @player.draw
    @barista.draw
    @computer.draw
    @coffee.draw
    @font.draw("Coffees consumed: #{@player.cups}", 30, 30, 10, 1, 1, 0xff_fffff)
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

  def talk_barista(barista)
    if Gosu::distance(@x, @y, barista.x, barista.y) < 80 then
      barista.set_talking
      if @money > 15 then
        puts 'ordered a coffee'
        @money = @money - 15
        barista.set_preping
      else
        puts 'not enough money'
      end
    else
      barista.set_walking
    end
  end

  def work_computer(computer)
    if computer.is_visible? then
      if Gosu::distance(@x, @y, computer.x, computer.y) < 30 then
        puts 'got some work to do'
        @money = @money + 5
        computer.toggle_visibility
      end
    end
  end

  def update(barista, computer)
    talk_barista barista
    work_computer computer
  end

  def draw
    @image.draw(@x, @y, ZOrder::Player)
  end

end

module ZOrder
  Background, Barista, Player, UI = *0..3
end

class Barista

  attr_accessor :is_preping, :x, :y

  def initialize
    @image = Gosu::Image.new('assets/player.png')
    
    @old_time_since = 0
    @time_since = 0
    @delta_time = 0

    @prep_time = 1000
    @timer = 0

    @is_preping = false
    @is_talking = false
    @walking_up = false
    @walking_speed = 2

    @y_min = 20
    @y_max = 550
    @x = @y = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def walking_dir
    if @y > @y_max then
      @walking_speed = -2
    end
    if @y < @y_min then
      @walking_speed = 2
    end
  end

  def moving
    if !@is_talking then
      walking_dir
      @y = @y + @walking_speed
    end
  end

  def set_talking
    @is_talking = true
  end

  def set_walking
    @is_talking = false
  end

  def set_preping
    @is_preping = true
  end

  def prep_coffee(coffee)
    if !@is_talking then
      
      @time_since = Gosu::milliseconds
      @delta_time = @time_since - @old_time_since
      @old_time_since = @time_since

      @timer = @timer + @delta_time
      if @timer > @prep_time then
        @timer = 0
        @is_preping = false
        coffee.set_ready
        puts "coffee is done"
      end
    end
  end

  def update(coffee)
    moving
    if @is_preping then
      prep_coffee(coffee)
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

  attr_accessor :is_visible, :x, :y

  def initialize
    @image = Gosu::Image.new('assets/player.png')
    @is_visible = false
    @time_to_activate = 300
    @timer = 0

    @old_time_since = 0
    @time_since = 0
    @delta_time = 0
    @x = @y = 0
  end

  def randNum
    (0..600).to_a.sample
  end

  def randPos
    @x, @y = randNum, randNum
  end

  def update
    if !is_visible? then
      prepare
    end
  end

  def prepare
   @time_since = Gosu::milliseconds
   @delta_time = @time_since - @old_time_since
   @old_time_since = @time_since

   @timer = @timer + @delta_time

   if @timer > @time_to_activate then
     @timer = 0
     randPos
     toggle_visibility
     puts 'more work'
   end
  end

  def toggle_visibility
    if @is_visible then
      @is_visible = false
    else
      @is_visible = true
    end
  end

  def is_visible?
    @is_visible
  end

  def draw
    if is_visible? then
      @image.draw(@x, @y, ZOrder::Barista)
    end
  end
end

class Coffee

  def initialize
    @image = Gosu::Image.new('assets/player.png')
    @is_visible = false
    @x = @y = 0
  end

  def draw
    if @is_visible then
      @image.draw(@x, @y, ZOrder::Barista)
    end
  end

end


window = GameWindow.new
window.show
