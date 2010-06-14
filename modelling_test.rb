require 'test/unit'
require 'modelling'

# this raises an error if the class vars are not initialized by
# default, we do this here before the unit tests below so we can
# test for this case before other classes start using their class
# level macros :) complete hack, but it fulfils the test criteria
class BlankSlate; include Modelling; end
BlankSlate.new

class User
  include Modelling
  attributes :name, :age
  collections :fav_colours, :biggest_gripes
end

class MyArray < Array; end
class MyHash < Hash; end

class Car
  include Modelling
  attributes :name => Proc.new { |car| String.new(car.class.to_s) }
  collections :doors => MyArray
end

class Site
  include Modelling
  maps :users => MyHash
end

class Bike
  include Modelling
  attributes :manufacturer
  maps :stickers
  structs :features
end

class ModellingTest < Test::Unit::TestCase

  def test_can_has_domain_builder
    assert Modelling
  end

  def test_user_has_name
    user = User.new
    user.name = 'Ryan'
    assert_equal 'Ryan', user.name
  end

  def test_user_has_age
    user = User.new
    user.age = 24
    assert_equal 24, user.age
  end

  def test_user_has_fav_colours_collection
    user = User.new
    user.fav_colours = [:green, :yellow]
    assert_equal [:green, :yellow], user.fav_colours
  end

  def test_user_has_biggest_gripes_collection
    user = User.new
    user.biggest_gripes = [:mediocrity, :CUB_beer]
    assert_equal [:mediocrity, :CUB_beer], user.biggest_gripes
  end

  def test_attributes_are_initialized_as_nil
    user = User.new
    assert_nil user.name
    assert_nil user.age
  end

  def test_collections_are_initialized_as_empty_array
    user = User.new
    assert_equal [], user.fav_colours
    assert_equal [], user.biggest_gripes
  end

  def test_can_initialize_with_attributes
    user = User.new(:name => 'Ryan')
    assert_equal 'Ryan', user.name
  end

  def test_can_initialize_with_collections
    user = User.new(:biggest_gripes => [:mediocrity, :CUB_beer])
    assert_equal [:mediocrity, :CUB_beer], user.biggest_gripes
  end

  def test_car_has_doors_and_all_is_good
    car = Car.new
    assert_equal [], car.doors
  end

  def test_bike_does_not_bunk_on_having_no_collection
    bike = Bike.new(:manufacturer => 'Kawasaki')
    # if nothing is rased, we fixed the bug
  end

  def test_bike_has_map_of_stickers
    assert_equal({}, Bike.new.stickers)
  end

  def test_cars_doors_is_a_my_array
    assert_kind_of MyArray, Car.new.doors
  end

  def test_sites_users_is_a_my_hash
    assert_kind_of MyHash, Site.new.users
  end

  def test_can_initialize_with_proc_and_get_reference_to_new_instance
    car = Car.new
    assert_equal String.new(car.class.to_s), car.name
  end

  def test_bike_has_features
    bike = Bike.new
    assert_kind_of OpenStruct, bike.features
  end

end
