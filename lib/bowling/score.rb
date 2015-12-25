require "bowling/score/version"

module Bowling
  class ScoreKeeper
    def initialize(*players)
      @players = players
      @frames = {}
      @current_frame = 0

      @players.collect do |player|
        @frames[player] = []
      end
    end

    def roll(pins, player)
      frame = @frames[player][@current_frame] || []
      frame << frame_chances(frame, pins)
      @frames[player][@current_frame] = frame
      @current_frame += 1 if !tenth_frame? && complete?(frame, pins)
    end

    def score(player)
      score = 0
      frames = @frames[player]

      frames.each_with_index do |frame, i|
        score += score_frame(frames, frame, i)
      end

      score
    end

    private
    def frame_chances(frame_chances, pins)
      if frame_chances.empty?
        pins
      elsif tenth_frame?
        score_tenth_frame(frame_chances, pins)
      elsif valid_frame_score?(frame_chances[0], pins)
        pins
      else
        raise ImpossibleNumberOfPins
      end
    end

    def complete?(frame, pins)
      frame.size == 2 || pins == 10
    end

    def score_tenth_frame(frame, pins)
      if two_unspared_chances?(frame) || frame.size == 3
        raise PlayerGameHasEnded
      elsif two_spared_chances?(frame, pins) || frame[0] == 10
        pins
      else
        raise ImpossibleNumberOfPins
      end
    end

    def valid_frame_score?(frame_pins, pins)
      frame_pins + pins <= 10
    end

    def two_unspared_chances?(frame)
      frame.size == 2 && frame.inject(:+) < 10
    end

    def two_spared_chances?(frame, pins)
      frame[0] < 10 && valid_frame_score?(frame[0], pins)
    end

    def score_frame(frames, frame, i)
      if i == 9 # tenth frame
        frame.inject(:+)
      elsif strike?(frame)
        strike_bonus(frames, i)
      elsif spare?(frame)
        spare_bonus(frames, i)
      else
        frame.inject(:+)
      end
    end

    def strike?(frame)
      frame == [10]
    end

    def strike_bonus(frames, i)
      next_frame = frames[i + 1]
      second_ball = next_frame[1] ? next_frame[1] : frames[i + 2][0]
      10 + next_frame[0] + second_ball
    end

    def spare?(frame)
      frame.size == 2 && frame.inject(:+) == 10
    end

    def spare_bonus(frames, i)
      10 + frames[i + 1][0]
    end

    def tenth_frame?
      @current_frame == 9
    end
  end

  class PlayerGameHasEnded < StandardError; end
  class ImpossibleNumberOfPins < StandardError; end
end
