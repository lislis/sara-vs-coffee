require ('gosu')

WIDTH = 960
HEIGHT = 640

COFFEE_PRICE = 15
SALARY = 5
CAFFEINE = 30

COUNTER = 760

class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = 'Sara vs Coffee'

    @state = 'game'
    @state_message = ''
    @output = Output.new
    @background = Gosu::Image.new('assets/background_pixel.png')

    @player = Player.new(@output)
    @player.warp(300, 300)

    @barista = Barista.new(@output)
    @barista.warp(40)

    @computer = Computer.new(@output)
    @coffee = Coffee.new

    @font = Gosu::Font.new(24)
  end

  def update

    if @state == 'game' then
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

      @player.update(@barista, @computer, @coffee)
      @computer.update
      @barista.update(@coffee)

      if @player.check_state == 'win' then
        set_state_message 'You win'
        @state = 'win'
      elsif @player.check_state == 'lose' then
        set_state_message 'You lose' 
        @state = 'lose'
      end
    end
  end

  def draw

    if @state == 'game' then
      
      @background.draw(0, 0, ZOrder::Background)
      @player.draw
      @barista.draw
      @computer.draw
      @coffee.draw
      @font.draw("Coffees consumed: #{@player.cups} of #{@player.cups_goal}", 20, 15, 10)
      @font.draw("Caffeine Level: #{@player.caffeine.ceil}", 20, 35, 11)
      @font.draw("Money available: #{@player.money}", 20, 55, 11)
      @font.draw(@output.output.to_s, 350, 500, 11)
    else
      @font.draw("#{@state_message}", 30, 30, 10, 1, 1)
    end

  end

  def set_state_message(msg)
    @state_message = msg
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

class Player

  attr_reader :cups, :caffeine, :cups_goal, :money

  def initialize(output)
   @output = output

   @image_back = Gosu::Image.new('assets/sara_back.png')
   @image_sad = Gosu::Image.new('assets/sara_sad.png')
   @image_happy = Gosu::Image.new('assets/sara_happy.png')
   @image_normal = Gosu::Image.new('assets/sara_normal.png')
   @image = @image_normal

   @typing = Gosu::Sample.new('sounds/typing.wav')
   @drinking = Gosu::Sample.new('sounds/gulp.wav')

   @x = @y = 0
   @caffeine = 50
   @money = 0
   @speed = 2.4

   @caffeine_min = 0
   @caffeine_max = 100

   @cups = 0
   @cups_goal = 20

   @old_time_since = 0
   @time_since = 0
   @delta_time = 0
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
    if Gosu::distance(@x, @y, barista.x, barista.y) < 120 then
      barista.set_talking
      if @money >= COFFEE_PRICE then
        @output.set_output "You ordered coffee"
        @money = @money - COFFEE_PRICE
        barista.set_preping
      else
        @output.set_output "You need more money"
      end
    else
      barista.set_walking
    end
  end

  def work_computer(computer)
    if computer.is_visible? then
      if Gosu::distance(@x, @y, computer.x, computer.y) < 40 then
        @typing.play
        output = "You made some money"
        @money = @money + SALARY
        computer.toggle_visibility
      end
    end
  end

  def drink_coffee(coffee)
    if coffee.is_visible? then
      if Gosu::distance(@x, @y, coffee.x, coffee.y) < 40 then
        @drinking.play
        @output.set_output "You drank cup of coffee"
        coffee.set_consumed
        @caffeine = @caffeine + CAFFEINE
        @speed = adjust_speed
        @cups = @cups + 1
      end
    end
  end

  def adjust_speed
    
    unless @speed < 1
      @caffeine * 0.1 - 1
    end
  end

  def decrease_caffeine
    @time_since = Gosu::milliseconds
    @delta_time = @time_since - @old_time_since
    @old_time_since = @time_since
    @caffeine = @caffeine - (@delta_time * 0.001)
    @speed = adjust_speed
  end

  def check_state
    if @cups >= @cups_goal then
      return 'win'
    end

    if @caffeine > @caffeine_max || @caffeine < @caffeine_min then
      return 'lose'
    end
      
  end

  def caffeine_level
    if @caffeine > 70 then
      @image = @image_happy
    elsif @caffeine < 40 then
      @image = @image_sad
    else
      @image = @image_normal
    end
  end

  def update(barista, computer, coffee)
    talk_barista barista
    work_computer computer
    drink_coffee coffee
    decrease_caffeine
    caffeine_level
  end

  def draw
    @image.draw(@x, @y, ZOrder::Player, 0.3, 0.3)
  end

end

module ZOrder
  Background, Barista, Player, UI = *0..3
end

class Output

  def initialize
    @output = ''
  end

  def output
    @output
  end
  
  def set_output(out)
    @output = out
  end
  
end

class Barista

  attr_accessor :is_preping, :x, :y

  def initialize(output)
    @output = output
    @image_front = Gosu::Image.new('assets/barista.png')
    @image_back = Gosu::Image.new('assets/barista_back.png')
    @image = @image_front

    @latte = Gosu::Sample.new('sounds/latte-maker.wav')
    
    @old_time_since = 0
    @time_since = 0
    @delta_time = 0

    @prep_time = 6000
    @timer = 0

    @is_preping = false
    @is_talking = false
    @walking_up = false
    @walking_speed = 2

    @y_min = 20
    @y_max = 480
    @x = COUNTER + 145
    @y = 0
  end

  def warp(y)
    @y = y
  end

  def walking_dir
    if @y > @y_max then
      @walking_speed = -2
      @image = @image_back
    end
    if @y < @y_min then
      @walking_speed = 2
      @image = @image_front
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
      if @timer >= @prep_time then
        @latte.play
        @timer = 0
        @is_preping = false
        coffee.set_ready
        @output.set_output "The barista fixed you a coffee"
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
    @image.draw(@x, @y, ZOrder::Barista, 0.15, 0.15)
  end
end

class Computer

  attr_accessor :is_visible, :x, :y

  def initialize(output)
    @output = output
    @image = Gosu::Image.new('assets/computer_1.png')
    @is_visible = false
    @time_to_activate = 1500
    @timer = 0

    @old_time_since = 0
    @time_since = 0
    @delta_time = 0
    @x = @y = 0
  end

  def randNum
    (0..580).to_a.sample
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
      @image.draw(@x, @y, ZOrder::Barista, 0.3, 0.3)
    end
  end
end

class Coffee

  attr_accessor :is_visible, :x, :y

  def initialize
    @image = Gosu::Image.new('assets/coffee_1.png')
    @is_visible = false
    @x = COUNTER + 10
    @y = 0
  end

  def randNum
    (0..560).to_a.sample
  end

  def randPos
    @y = randNum
  end

  def set_ready
    @is_visible = true
    randPos
  end

  def is_visible?
    @is_visible
  end

  def set_consumed
    @is_visible = false
  end

  def draw
    if @is_visible then
      @image.draw(@x, @y, ZOrder::Barista, 0.3, 0.3)
    end
  end

end


window = GameWindow.new
window.show
