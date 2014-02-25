module MyMongoid
  class DuplicateFieldError < RuntimeError
  end

  class UnknownAttributeError < RuntimeError
  end

  class UnconfiguredDatabaseError < RuntimeError
  end
end
