require ('gosu')

class GameWindow < Gosu::Window
  def initialize
    super 960, 640
    self.caption = 'Sara vs Coffee'


    @player = Player.new
    @player.warp(50,50)
   end

  def update
  end

  def draw
    @player.draw
  end
end

class Player
  def initialize
   @image = Gosu::Image.new('assets/player.png')
   @x = @y = @vel_x = @vel_y = @angle = 0.0
   @caffeine = 0
   @money = 0
   @speed = 1

   @caffeine_min = 0
   @caffeine_max = 100

   @cups = 0
   @cups_goal = 100
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end

end

window = GameWindow.new
window.show
