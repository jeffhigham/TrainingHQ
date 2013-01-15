require 'helper'

class TestLap < Test::Unit::TestCase
  should "exist" do
    assert Guppy::Lap.new
  end

  context "attributes" do
    should "have a distance" do
      assert_equal 0.0, Guppy::Lap.new.distance
    end

    should "have a max_speed" do
      assert_equal 0.0, Guppy::Lap.new.max_speed
    end
    
    should "have a time" do
      assert_equal 0.0, Guppy::Lap.new.time
    end
    
    should "have a calories" do
      assert_equal 0, Guppy::Lap.new.calories
    end
    
    should "have a average_heart_rate" do
      assert_equal 0, Guppy::Lap.new.average_heart_rate
    end
    
    should "have a max_heart_rate" do
      assert_equal 0, Guppy::Lap.new.max_heart_rate
    end

    should "have track_points" do
      assert_equal [], Guppy::Lap.new.track_points
    end
  end
end

