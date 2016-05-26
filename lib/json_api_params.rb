# XXX Though these are necessary, AC::Parameters doesn't require it
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'date'
require 'rack/test/uploaded_file'

require 'action_controller/metal/strong_parameters'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'

class ActionController::Parameters
  def extract_json_api
    case data = fetch(:data)
    when Array
      return data.map {|_data|
        self.class.new(data: _data).extract_json_api
      }
    end

    relationships = data.fetch(:relationships) { self.class.new }

    attributes = self.class.new(data.fetch(:attributes) { self.class.new }.to_unsafe_hash.map {|key, value|
      [key.underscore, value]
    }.to_h)

    relationships.to_unsafe_hash.with_indifferent_access.each_with_object(attributes) {|(key, value), attrs|
      k = key.underscore

      case _data = value.fetch(:data)
      when Array
        attrs["#{k}_ids"] = _data.map {|item|
          item.fetch(:id)
        }
      else
        attrs["#{k}_id"] = _data.try(:fetch, :id)
      end
    }
  end
end
