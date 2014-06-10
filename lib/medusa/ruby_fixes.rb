
# These fixes ensure that DRb sends a reference to a Queue or ConditionVariable
# instead of a dumped object. Without this, Ruby 2.1 segfaults.
class Queue
  def marshal_dump
    raise TypeError, "Can't dump a Queue"
  end
end

class ConditionVariable
  def marshal_dump
    raise TypeError, "Can't dump a ConditionVariable"
  end
end  