require 'test_helper'

class JsonApiParamsTest < Minitest::Test
  def test_simple
    params = ActionController::Parameters.new(
      data: {
        attributes: {
          'x-y': 1,
          z:     2
        },
        relationships: {
          'foo-bar': {
            data: {
              id: 42
            }
          },
          baz: {
            data: nil
          },
          qux: {
            data: [{
              id: 3
            }, {
              id: 4
            }]
          }
        }
      }
    )

    expected = ActionController::Parameters.new(
      x_y:         1,
      z:           2,
      foo_bar_id: 42,
      baz_id:      nil,
      qux_ids:    [3, 4]
    )

    assert { params.extract_json_api == expected }
  end

  # http://jsonapi.org/extensions/bulk/
  def test_bulk
    params = ActionController::Parameters.new(
      data: [{
        type: 'photos',
        attributes: {
          title: 'Ember Hamster',
          src:   'http://example.com/images/productivity.png'
        }
      }, {
        type: 'photos',
        attributes: {
          title: 'Mustaches on a Stick',
          src:   'http://example.com/images/mustaches.png'
        }
      }]
    )

    expected = [
      ActionController::Parameters.new(
        title: 'Ember Hamster',
        src:   'http://example.com/images/productivity.png'
      ),
      ActionController::Parameters.new(
        title: 'Mustaches on a Stick',
        src:   'http://example.com/images/mustaches.png'
      )
    ]

    assert { params.extract_json_api == expected }
  end
end
