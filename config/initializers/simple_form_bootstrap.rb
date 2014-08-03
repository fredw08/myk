module AngularHelperExtensions
  def ng_input(attribute_name, options = {}, &block)
    @ng_attr_name = attribute_name.to_s
    if options[:js_obj]
      @ng_attr_name.prepend "#{options[:js_obj]}."
    else
      @ng_attr_name.prepend(
        object_name.gsub(/\[(.*?)(_attributes)?\]/) do |exp|
          ".#{$1}"
        end + '.'
      )
    end

    @attr_value = object.try(attribute_name)

    options = if options[:as] == :check_boxes
                handle_angular_collection_checkboxes(attribute_name, options)
              else
                handle_regular_angular_inputs(attribute_name, options)
              end
    input(attribute_name, options, &block)
  end

  def handle_angular_collection_checkboxes(attribute_name, options)
    ng_init_attr = "#{@ng_attr_name}='#{@attr_value}'"

    options[:collection] = options[:collection].map do |c|
      [
        c[0],
        c[1],
        ng_init:    ng_init_attr,
        ng_checked: "#{@ng_attr_name}.indexOf('#{c[1]}') >= 0",
        ng_model: @ng_attr_name
      ]
    end
    options
  end

  def handle_regular_angular_inputs(attribute_name, options)
    options.deep_merge!({input_html: {ng_model: @ng_attr_name}})

    ng_init_attr = case @attr_value
                   when Fixnum, Float, Integer, BigDecimal
                     "#{@ng_attr_name}=#{@attr_value}"
                   when String, Date, TrueClass, FalseClass, NilClass
                     "#{@ng_attr_name}='#{@attr_value}'"
                   end
    options[:input_html].merge!({ng_init: ng_init_attr}) if ng_init_attr
    options
  end
end

class SimpleForm::FormBuilder
  include AngularHelperExtensions
end

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.button_class = 'btn btn-default'
  config.boolean_label_class = nil

  config.wrappers :vertical_form, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'

    b.wrapper tag: 'div' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :vertical_file_input, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'

    b.wrapper tag: 'div' do |ba|
      ba.use :input
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :vertical_boolean, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder

    b.wrapper tag: 'div', class: 'checkbox' do |ba|
      ba.use :label_input
    end

    b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :vertical_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label_input, class: 'control-label'
    b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :horizontal_form_small, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-4 control-label'

    b.wrapper tag: 'div', class: 'col-sm-8' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_form, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-3 control-label'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_file_input, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'col-sm-3 control-label'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder

    b.wrapper tag: 'div', class: 'col-sm-offset-3 col-sm-9' do |wr|
      wr.wrapper tag: 'div', class: 'checkbox' do |ba|
        ba.use :label_input, class: 'col-sm-9'
      end

      wr.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      wr.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'mt-error' do |b|
    b.use :html5
    b.use :placeholder

    b.use :label, class: 'col-sm-3 control-label'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint,  wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  # Wrappers for forms and inputs using the Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :vertical_form
end
