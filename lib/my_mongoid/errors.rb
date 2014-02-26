module MyMongoid
  class DuplicateFieldError < RuntimeError
  end

  class UnknownAttributeError < RuntimeError
  end

  class UnconfiguredDatabaseError < RuntimeError
  end

  class RecordNotFoundError < RuntimeError
  end
end
