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

RSpec.describe Modelling do

  specify 'user has name' do
    user = User.new
    user.name = 'Ryan'
    expect(user.name).to eq 'Ryan'
  end

  specify 'user has age' do
    user = User.new
    user.age = 24
    expect(user.age).to eq 24
  end

  specify 'user has fav colours collection' do
    user = User.new
    user.fav_colours = [:green, :yellow]
    expect(user.fav_colours).to eq [:green, :yellow]
  end

  specify 'user has biggest gripes collection' do
    user = User.new
    user.biggest_gripes = [:mediocrity, :CUB_beer]
    expect(user.biggest_gripes).to eq [:mediocrity, :CUB_beer]
  end

  specify 'attributes are initialized as nil' do
    user = User.new
    expect(user.name).to be_nil
    expect(user.age).to be_nil
  end

  specify 'collections are initialized as empty array' do
    user = User.new
    expect(user.fav_colours).to be_empty
    expect(user.biggest_gripes).to be_empty
  end

  it 'can initialize with attributes' do
    user = User.new(:name => 'Ryan')
    expect(user.name).to eq 'Ryan'
  end

  it 'can initialize with collections' do
    user = User.new(:biggest_gripes => [:mediocrity, :CUB_beer])
    expect(user.biggest_gripes).to eq [:mediocrity, :CUB_beer]
  end

  specify 'car has doors and all is good' do
    car = Car.new
    expect(car.doors).to be_empty
  end

  specify 'bike does not bunk on having no collection' do
    bike = Bike.new(:manufacturer => 'Kawasaki')
    # if nothing is rased, we fixed the bug
  end

  specify 'bike has map of stickers' do
    expect(Bike.new.stickers).to be_empty
  end
  
  specify 'cars doors is a my array' do
    expect(Car.new.doors).to be_instance_of MyArray
  end
  
  specify 'sites users is a my hash' do
    expect(Site.new.users).to be_instance_of MyHash
  end
  
  it 'can initialize with proc and get reference to new instance' do
    car = Car.new
    expect(car.name).to eq String.new(car.class.to_s)
  end

  specify 'bike has features' do
    bike = Bike.new
    expect(bike.features).to be_instance_of OpenStruct
  end

  it 'doesnt fail when lambdas with no args are used' do
    expect(LambdaTest.new.lambda).to eq 'boo'
  end
  
  specify 'tracks list of accessors' do
    expect(User.accessors).to include :name, :age
  end
  
  specify 'provides a Hash of attributes and values' do
    expect(User.new.attributes.key?(:name)).to be true
    expect(User.new.attributes.key?(:age)).to be true
    expect(User.new(:name => "Joe").attributes[:name]).to eq "Joe"
  end
  
  specify 'converts the attributes hash to a string for inspect' do
    u = User.new(:name => "Joe")
    expect(u.inspect).to eq("#<User name: \"Joe\", age: nil, test: 3, fav_colours: [], biggest_gripes: []>")
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
      expect { FirstModel.new.inspect }.not_to raise_error
    end
    
    it 'should show the class name instead of inspecting referenced models' do
      expect(FirstModel.new.inspect).to include("#<OtherModel>")
    end
    
  end
  
  
  
  context 'inheritence' do
    let(:car) { Car.new }
    let(:super_car) { SuperCar.new }

    it 'inherits attributes' do
      expect(super_car.doors).to be_instance_of MyArray
      expect(super_car.name).to eq "SuperCar"
    end

    it 'allows extra attributes' do
      expect(super_car.bhp).to eq 400
    end

    it 'doesnt mess up the super classes members' do
      expect(car).not_to respond_to(:bhp)
      expect(car).to respond_to(:doors)
      expect(car).to respond_to(:name)
    end

    specify 'non specific user inherits attributes' do
      user = NonSpecificUser.new(:name => 'Ryan you cocktard')
      expect(user.name).to eq 'Ryan you cocktard'
    end
  end
end
