require 'date'

class MockRedis
  module StreamsMethods
    def xadd(key, id, *args)
      return "#{DateTime.now.strftime('%Q')}-0" if id == '*'
    end
  end
end
