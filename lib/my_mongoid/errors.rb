module MyMongoid
  class DuplicateFieldError < RuntimeError
  end

  class UnknownAttributeError < RuntimeError
  end
end
