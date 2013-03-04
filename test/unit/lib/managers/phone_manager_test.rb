require 'test_helper'

class PhoneManagerTest < ActiveSupport::TestCase
  
  TEST_ATTRIBUTES_FILENAME = "attributes_test.json"
  
  def setup
    Managers::PhoneManager.check_and_create_attributes_file(TEST_ATTRIBUTES_FILENAME)
  end
  
  def reset
    Managers::PhoneManager.delete_file(TEST_ATTRIBUTES_FILENAME)
  end
  
  def test_add_attribute_ok
    setup
    
    attribute = { "name" => "baterry" }
    result = Managers::PhoneManager.add_phone_attribute(attribute, TEST_ATTRIBUTES_FILENAME)
    attributes = Managers::PhoneManager.get_attributes(TEST_ATTRIBUTES_FILENAME)
    
    expected_result = {:status => true, :message => "Attribute added", :attribute => { "name" => "baterry" }}
    assert_equal attribute, attributes[0]
    assert_equal expected_result, result
    
    reset
  end
  
  def test_add_attribute_not_valid
    setup
    
    attribute = { "some" => "baterry" }
    result = Managers::PhoneManager.add_phone_attribute(attribute, TEST_ATTRIBUTES_FILENAME)
    attributes = Managers::PhoneManager.get_attributes(TEST_ATTRIBUTES_FILENAME)
    
    expected = {:status => false, :message => "Attribute not valid", :attribute => nil}
    assert_blank attributes
    assert_equal expected, result
    
    reset
  end
  
  def test_add_attribute_exists
    setup
    
    attribute = { "name" => "baterry" }
    result = Managers::PhoneManager.add_phone_attribute(attribute, TEST_ATTRIBUTES_FILENAME)
    result = Managers::PhoneManager.add_phone_attribute(attribute, TEST_ATTRIBUTES_FILENAME)
    attributes = Managers::PhoneManager.get_attributes(TEST_ATTRIBUTES_FILENAME)
    
    expected_result = {:status => false, :message => "Attribute exists", :attribute => attribute}
    
    assert_equal [attribute], attributes
    assert_equal expected_result, result
    
    reset
  end
  
  def test_parse_attribute_ok    
    attribute = { "name" => "baterry", "unit" => "mAh", "field1" => "value1", "field2" => "value2" }
    parsed_attribute = Managers::PhoneManager.parse_attribute(attribute)
    
    expected = { "name" => "baterry", "unit" => "mAh" }
    assert_equal expected, parsed_attribute    
  end
  
  def test_parse_attribute_required_fields_missing    
    attribute = { "unit" => "mAh", "field1" => "value1", "field2" => "value2" }
    parsed_attribute = Managers::PhoneManager.parse_attribute(attribute)
    
    expected = nil
    assert_equal expected, parsed_attribute    
  end
  
  def test_parse_attribute_required_fields_empty    
    attribute = { "name" => "" }
    parsed_attribute = Managers::PhoneManager.parse_attribute(attribute)
    
    expected = nil
    assert_equal expected, parsed_attribute
  end
  
end