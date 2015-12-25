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
      @current_frame += 1 if !tenth_frame? && (frame.size == 2 || pins == 10)
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
      elsif (frame_chances[0] + pins) <= 10
        pins
      else
        raise ImpossibleNumberOfPins
      end
    end

    def score_tenth_frame(frame, pins)
      if (frame.size == 2 && frame.inject(:+) < 10) || frame.size == 3
        raise PlayerGameHasEnded
      else
        pins
      end
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
