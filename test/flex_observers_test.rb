require 'test_helper'

class User < ActiveRecord::Base
end

class UserObserver < ActiveRecord::Observer
  observe :user
  
  def before_save(record)
    record.name = "Ninja"
  end
end

class FlexObserversTest < ActiveSupport::TestCase
  load_schema
  
  def setup
    ActiveRecord::Base.observers = :user_observer
    UserObserver.instance
  end
  test "observers should work as normal if we no skip its" do
    ian = User.new({ :name => "Ian" })
    ian.save
    assert_equal "Ninja", ian.name
  end
  test "observing should not activate observer if skip_observers is used" do
    person = User.new({ :name => "Joe Doe" })
    person.without_observers("UserObserver") do
      person.save
    end
    assert_not_equal "Ninja", person.name
  end
  test "without_observers should restore normal behavior after it was used" do
    person = User.new({ :name => "Joe Doe" })
    person.without_observers("UserObserver") do
      person.save
    end
    assert_not_equal "Ninja", person.name
    person.save
    assert_equal "Ninja", person.name
  end
  test "observing should not activate observer if all observer are skipt" do
    person = User.new({ :name => "Joe Doe" })
    person.without_observers("*") do
      person.save
    end
    assert_not_equal "Ninja", person.name
  end
  test "without_observers should restore normal behavior when all observer used" do
    person = User.new({ :name => "Joe Doe" })
    person.without_observers("*") do
      person.save
    end
    assert_not_equal "Ninja", person.name
    person.save
    assert_equal "Ninja", person.name
  end
end
