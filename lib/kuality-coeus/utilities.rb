module Utilities

  include StringFactory

  def get(item)
    instance_variable_get(snakify(item))
  end

  def set(item, obj)
    instance_variable_set(snakify(item), obj)
  end

  def make_user(opts={})
    un=opts[:user]
    role=opts[:role]
    un ||= role
    $users << set(un, (make UserObject, opts))
    $users[-1]
  end

  def random_percentage
    random_dollar_value(100)
  end

  private

  def snakify(item)
    item.to_s[0]=='@' ? item : "@#{damballa(item.to_s)}"
  end

end