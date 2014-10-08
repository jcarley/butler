class StrongParameters

  attr_reader :route, :group

  def initialize(route, group)
    @route = route
    @group = group
  end

  def permit!(hash)
    group_value = hash[group]
    attrs = attributes_for_group(group, group_value, true)
    symbolize_recursive(attrs)
  end

  def attributes_for_group(group_key, hash, include_group = true)
    route_keys = RouteKeys.new(route, group_key)
    keys_regex = route_keys.keys_regex
    keys = route_keys.keys

    attrs = attributes_for(keys, hash, :keys_regex => keys_regex)

    include_group ? {group_key => attrs} : attrs
  end

  def attributes_for(keys, hash, options = {})

    keys_regex = options[:keys_regex]

    attrs = {}
    keys.each do |key|
      sub_key = key.match(keys_regex)[2]
      next if sub_key.empty?
      if hash[sub_key].present? || (hash.has_key?(sub_key) && hash[sub_key] == false)
        value = hash[sub_key]
        if value.is_a?(Hash)
          attrs[sub_key] = attributes_for_group(key, value, false)
        else
          attrs[sub_key] = value
        end
      end
    end

    attrs
  end

  def symbolize_recursive(hash)
    {}.tap do |h|
      hash.each { |key, value| h[key.to_sym] = map_value(value) }
    end
  end

  def map_value(value)
    case value
    when Hash
      symbolize_recursive(value)
    when Array
      value.map { |v| map_value(v) }
    else
      value
    end
  end

end

class RouteKeys

  attr_reader :route, :group, :keys_regex

  def initialize(route, group)
    @route = route
    @group = group
    group_key = group.to_s.gsub('[', '\[').gsub(']', '\]')
    @keys_regex = /^(#{group_key})(?:\[(\w*)\])?$/
  end

  def keys
    route_keys = route.route_params.select { |k, v| k.to_s.match(keys_regex) }.keys
    route_keys.delete(group.to_s)
    route_keys.sort
  end

end
