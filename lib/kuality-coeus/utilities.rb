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

  def make_role(opts={})
    name = opts[:name]
    name ||= 'role'
    set(name, (make RoleObject, opts))
  end

  def random_percentage
    random_dollar_value(100)
  end

  def days_in_month(year, month)
    Date.new(year, month, -1).day.to_i
  end
  module_function :days_in_month

  def datify(date_string)
    Date.strptime date_string, '%m/%d/%Y'
  end
  module_function :datify

  private

  def snakify(item)
    item.to_s[0]=='@' ? item : "@#{damballa(item.to_s)}"
  end

end