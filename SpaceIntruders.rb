require 'gosu'

module ZOrder
	Background, Actors, UI = *0..2
end

class Enemy
	def initialize(window, x, y)
		@x, @y = x, y
		@image = Gosu::Image.new(window, "media/Starfighter.bmp")
		@health = 100
		@exploded = false
	end

	def draw
		if @exploded
			#@image.draw_rot(@x, @y, 1, 90.0)
		else
			@image.draw_rot(@x, @y, 1, 180.0)
		end	
	end

	def hit_by(bullets)
        @exploded = @exploded || bullets.any? {|bullet| Gosu::distance(bullet.x, bullet.y, @x, @y) < 22}
    end
end

class Bullet
	attr_reader :x, :y

	def initialize(window, x, y)
		@image = Gosu::Image.new(window, "media/Bullet.png")
		@x, @y = x, y
		#@direction = up
	end

	def draw
		@image.draw(@x, @y, ZOrder::Actors, 1, 1, 0xffffffff, :add)
	end

	def move
		@y -= 5
	end
end

class Player
	attr_reader :x, :y

	def initialize(window)
		@image = Gosu::Image.new(window, "media/Starfighter.bmp")
		@last_shot = Time.now
		@window = window
	end

	def warp(x, y)
		@x, @y = x, y
	end

	def move_left
		if @x > 32
			@x -= 5
		end
	end

	def move_right
		if @x < 608
			@x += 5
		end
	end

	def shoot(bullets)
		if (Time.now - @last_shot) > 0.2
			bullets.push(Bullet.new(@window, @x-1, @y-20))
			@last_shot = Time.now
		end
	end

	def draw
		@image.draw_rot(@x, @y, 1, 0)
	end
end

class GameWindow < Gosu::Window
	def initialize
		super(640, 480, false)
		self.caption = 'SPACE INTRUDERS'

		@background_image = Gosu::Image.new(self, "media/Space.png")

		@player = Player.new(self)
		@player.warp(320, 420)

		@enemies = Array.new
		(1..5).to_a.each { |x| @enemies.push(Enemy.new(self, 105 * x, 60)) }

		@bullets = Array.new
	end

	def update
		if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
			@player.move_left
		end
		if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
	  	@player.move_right
	  end
	  if button_down? Gosu::KbSpace
	  	@player.shoot(@bullets)
	  end

	  @bullets.each { |bullet| bullet.move }
	  @enemies.each { |enemy| enemy.hit_by(@bullets) }

	end

	def draw
		@background_image.draw(0,0,ZOrder::Background)
		@player.draw
		@bullets.each { |bullet| bullet.draw }
		@enemies.each { |enemy| enemy.draw }
	end
end

window = GameWindow.new
window.show
