require 'spec_helper'

describe Bowling::ScoreKeeper do
  let(:score_keeper) { Bowling::ScoreKeeper.new('Rick', 'Morty') }

  it 'rolls for a player' do
    score_keeper.roll(0, 'Rick')
    expect(score_keeper.score('Rick')).to eq(0)
  end

  it 'rolls for 2 players' do
    score_keeper.roll(0, 'Rick')
    score_keeper.roll(9, 'Morty')

    expect(score_keeper.score('Morty')).to eq(9)
  end

  it 'rolls for a frame' do
    score_keeper.roll(1, 'Rick')
    score_keeper.roll(8, 'Rick')

    expect(score_keeper.score('Rick')).to eq(9)
  end

  it 'scores a game of gutters' do
    20.times { score_keeper.roll(0, 'Rick') }
    expect(score_keeper.score('Rick')).to eq(0)
  end

  it 'scores a game of 1s' do
    20.times { score_keeper.roll(1, 'Rick') }
    expect(score_keeper.score('Rick')).to eq(20)
  end

  it 'scores a game of 1s and a spare' do
    17.times { score_keeper.roll(1, 'Rick') } # terrible 8.5 frames
    score_keeper.roll(9, 'Rick')              # spare in the 9th frame
    2.times { score_keeper.roll(1, 'Rick') }  # terrible tenth frame

    expect(score_keeper.score('Rick')).to eq(29)
  end

  it 'scores a game of 1s and a strike' do
    16.times { score_keeper.roll(1, 'Rick') } # terrible 8 frames
    score_keeper.roll(10, 'Rick')             # strike in the 9th frame
    2.times { score_keeper.roll(1, 'Rick') }  # terrible tenth frame

    expect(score_keeper.score('Rick')).to eq(30)
  end

  it 'scores multiple strikes' do
    14.times { score_keeper.roll(1, 'Rick') } # terrible 7 frames
    score_keeper.roll(10, 'Rick')             # strike in the 8th frame
    score_keeper.roll(10, 'Rick')             # strike in the 9th frame
    2.times { score_keeper.roll(1, 'Rick') }  # terrible tenth frame

    expect(score_keeper.score('Rick')).to eq(49)
  end

  it 'scores a perfect game' do
    12.times { score_keeper.roll(10, 'Rick') }
    expect(score_keeper.score('Rick')).to eq(300)
  end

  it 'plays a boring 10th frame' do
    9.times { score_keeper.roll(10, 'Rick') }
    2.times { score_keeper.roll(1, 'Rick') }

    expect(score_keeper.score('Rick')).to eq(245)
    expect {
      score_keeper.roll(1, 'Rick')
    }.to raise_error(Bowling::PlayerGameHasEnded)
  end

  it 'plays a spared 10th frame' do
    9.times { score_keeper.roll(10, 'Rick') }
    score_keeper.roll(1, 'Rick')
    score_keeper.roll(9, 'Rick')
    score_keeper.roll(5, 'Rick')

    expect(score_keeper.score('Rick')).to eq(266)
    expect {
      score_keeper.roll(1, 'Rick')
    }.to raise_error(Bowling::PlayerGameHasEnded)
  end

  it 'prevents bogus scores' do
    score_keeper.roll(1, 'Rick')
    expect {
      score_keeper.roll(10, 'Rick')
    }.to raise_error(Bowling::ImpossibleNumberOfPins)
  end
end
