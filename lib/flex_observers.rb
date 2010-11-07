module ActiveModel
  class Observer
    alias_method :__old_update, :update
    
    def update(observed_method, object)
      this_observer = self.class.to_s
      skip_observers = object.skip_observers
      unless skip_observers[this_observer] || skip_observers["*"] || skip_observers[:all]
        __old_update(observed_method, object)
      end
    end
  end

  module Observing
    def skip_observers
      @_skip_observers ||= { }
    end

    def without_observers(*observers, &block)
      increase_counter_to_skip_observers(*observers)
      block.call
      decrease_counter_to_skip_observers(*observers)
    end

    private
    def increase_counter_to_skip_observers(*observers)
      observers.each do |observer|
        increase_counter_to_skip_observer(observer)
      end
    end
    
    def increase_counter_to_skip_observer(observer)
      skip_observers[observer] ? skip_observers[observer] += 1 : skip_observers[observer] = 1 
    end

    def decrease_counter_to_skip_observers(*observers)
      observers.each do |observer|
        decrease_counter_to_skip_observer(observer)
      end
    end
    def decrease_counter_to_skip_observer(observer)
      if skip_observers[observer]
        skip_observers[observer] -= 1
        skip_observers.delete(observer) if skip_observers[observer] <= 0
      end
    end
  end
end
