require 'bundler'
Bundler.require
$: << '.'
require 'modelling'

class User
  include Modelling
  attributes :name, :age
  collections :fav_colours, :biggest_gripes, :test => lambda { 3 }
end

class NonSpecificUser < User
end

class MyArray < Array; end
class MyHash < Hash; end

class Car
  include Modelling
  attributes :name => Proc.new { |car| String.new(car.class.to_s) }
  collections :doors => MyArray
end

class SuperCar < Car
  attributes :bhp => Proc.new { 400 }
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

class LambdaTest
  include Modelling
  attributes :lambda => lambda { "boo" }
end

describe Modelling do

  specify 'user has name' do
    user = User.new
    user.name = 'Ryan'
    user.name.should  eq 'Ryan'
  end

  specify 'user has age' do
    user = User.new
    user.age = 24
    user.age.should  eq 24
  end

  specify 'user has fav colours collection' do
    user = User.new
    user.fav_colours = [:green, :yellow]
    user.fav_colours.should  eq [:green, :yellow]
  end

  specify 'user has biggest gripes collection' do
    user = User.new
    user.biggest_gripes = [:mediocrity, :CUB_beer]
    user.biggest_gripes.should  eq [:mediocrity, :CUB_beer]
  end

  specify 'attributes are initialized as nil' do
    user = User.new
    user.name.should be_nil
    user.age.should be_nil
  end

  specify 'collections are initialized as empty array' do
    user = User.new
    user.fav_colours.should be_empty
    user.biggest_gripes.should be_empty
  end

  it 'can initialize with attributes' do
    user = User.new(:name => 'Ryan')
    user.name.should  eq 'Ryan'
  end

  it 'can initialize with collections' do
    user = User.new(:biggest_gripes => [:mediocrity, :CUB_beer])
    user.biggest_gripes.should  eq [:mediocrity, :CUB_beer]
  end

  specify 'car has doors and all is good' do
    car = Car.new
    car.doors.should be_empty
  end

  specify 'bike does not bunk on having no collection' do
    bike = Bike.new(:manufacturer => 'Kawasaki')
    # if nothing is rased, we fixed the bug
  end

  specify 'bike has map of stickers' do
    Bike.new.stickers.should be_empty
  end
  
  specify 'cars doors is a my array' do
    Car.new.doors.should be_instance_of MyArray
  end
  
  specify 'sites users is a my hash' do
    Site.new.users.should be_instance_of MyHash
  end
  
  it 'can initialize with proc and get reference to new instance' do
    car = Car.new
    car.name.should  eq String.new(car.class.to_s)
  end

  specify 'bike has features' do
    bike = Bike.new
    bike.features.should be_instance_of OpenStruct
  end

  it 'doesnt fail when lambdas with no args are used' do
    LambdaTest.new.lambda.should  eq 'boo'
  end
  
  specify 'tracks list of accessors' do
    User.accessors.should include :name, :age
  end
  
  specify 'provides a Hash of attributes and values' do
    User.new.attributes.key?(:name).should be_true
    User.new.attributes.key?(:age).should be_true
    User.new(:name => "Joe").attributes[:name].should eq "Joe"
  end
  
  specify 'converts the attributes hash to a string for inspect' do
    u = User.new(:name => "Joe")
    u.inspect.should == "#<User name: \"Joe\", age: nil, test: 3, fav_colours: [], biggest_gripes: []>"
  end
  
  context 'circular references' do
    
    before do
      class FirstModel
        include Modelling
        attributes :test => lambda { |me| OtherModel.new(me) }
      end

      class OtherModel
        include Modelling
        attributes :owner
        def initialize(owner)
          @owner = owner
        end
      end
    end
    
    it 'should not raise an error when inspecting' do
      expect { FirstModel.new.inspect }.should_not raise_error(SystemStackError)
    end
    
    it 'should show the class name instead of inspecting referenced models' do
      FirstModel.new.inspect.should include("#<OtherModel>")
    end
    
  end
  
  
  
  context 'inheritence' do
    let(:car) { Car.new }
    let(:super_car) { SuperCar.new }

    it 'inherits attributes' do
      super_car.doors.should be_instance_of MyArray
      super_car.name.should  eq "SuperCar"
    end

    it 'allows extra attributes' do
      super_car.bhp.should  eq 400
    end

    it 'doesnt mess up the super classes members' do
      car.should_not respond_to(:bhp)
      car.should respond_to(:doors)
      car.should respond_to(:name)
    end

    specify 'non specific user inherits attributes' do
      user = NonSpecificUser.new(:name => 'Ryan you cocktard')
      user.name.should  eq 'Ryan you cocktard'
    end
  end
end
