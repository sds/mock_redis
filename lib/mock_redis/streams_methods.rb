class MockRedis
  module StreamsMethods
    def xadd(key, id, *args)
      return "#{Time.now.to_i}-0" if id == '*'
    end
  end
end
