module ApplicationHelper
  def t_options(key)
    I18n.t(key, scope: 'select_options')
  end

  def t_a(key)
    I18n.t(key, scope: 'activerecord.attributes', default: '')
  end

  def t_option_str(key, code)
    (t_options(key).find { |v| v[1] == code } || [''])[0]
  end

  def t_title(action = nil)
    resource_name, action_name = controller.controller_name, controller.action_name
    title = if action
              t(action, default: '', scope: [:title, resource_name])
            else
              t(action_name, default: [:default, ''], scope: [:title, resource_name])
            end
    if title == ''
      title = if action_name == 'index'
                "listing #{resource_name}"
              elsif action_name == 'show'
                "#{resource_name.singularize} details"
              else
                case action_name
                when 'create' then 'new'
                when 'update' then 'edit'
                else action_name
                end + " #{resource_name.singularize}"
              end.titleize
    end
    title
  end

  def new_resource_path(options = {})
    new_polymorphic_path(resource_name, options)
  end

  def edit_resource_path(options = {})
    edit_polymorphic_path(resource_instance, options)
  end

  def resources_path(options = {})
    polymorphic_path(controller_name, options)
  end

  def form_cancel_resource_path(options = {})
    if resource_instance.new_record?
      polymorphic_path(resource_class, options)
    else
      polymorphic_path(resource_instance, options)
    end
  end

  # make will_paginate default renderer to use bootstrap renderer
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge renderer: BootstrapPagination::Rails
    end
    super(*[collection_or_options, options].compact)
  end

  def readonly(ro = nil)
    ro ||= (params[:action] == 'show')
    ro ? 'readonly' : nil
  end

  def to_dollar(number)
    number_with_precision number, precision: 2, delimiter: ","
  end

  def span_with_tooltip(content, tooltip)
    content_tag :span, content, title: tooltip
  end

  def sortable(title, increment = 1)
    @column_idx = 0 unless defined?(@column_idx)
    @column_idx += increment
    index = @column_idx.to_s

    css_class = index == sort_column ? sort_direction : "sorting"
    direction = index == sort_column && sort_direction == "asc" ? "desc" : "asc"

    values = {sort: index, dir: direction}

    values[:filter_by] = params[:filter_by] if params[:filter_by].present?
    values[:status]    = params[:status]    if params[:status].present?

    if params[:search].present? && params[:search][:keyword].present?
      values[:search] = {keyword: params[:search][:keyword]}
    end
    values[:per_page] = params[:per_page] if params[:per_page].present?
    values[:type_id] = params[:type_id] if params[:type_id].present?
    values[:show_tab] = params[:show_tab] if params[:show_tab].present?

    sort_icon = content_tag('i', nil, class: "fa #{index == sort_column ? sort_icon(sort_direction) : ''}")

    link_to sort_icon + '  ' + title, values, {class: css_class}
  end

  def web_sortable(title, reset = false)
    @column_idx = 0 if reset || !defined?(@column_idx)
    @column_idx += 1
    index = @column_idx.to_s

    css_class = index == sort_column ? "#{web_sort_direction} loading sorting" : "loading sorting"
    direction = index == sort_column && web_sort_direction == "asc" ? "desc" : "asc"

    values    = {sort: index, dir: direction}
    sort_icon = content_tag('i', nil, class: "fa #{index == sort_column ? sort_icon(web_sort_direction) : ''}")

    link_to sort_icon + '  ' + title, params.merge(values), {class: css_class}
  end

  def hidden_search_fields
    %I[per_page page sort dir status type_id show_tab].map do |k|
      content_tag(:input, nil, {type: :hidden, name: k, value: params[k]}) if params[k].present?
    end.join
  end

  def sort_icon(dir)
    dir == 'asc' ? 'fa-caret-up' : 'fa-caret-down'
  end

  def label_it(str, locale, css_class)
    content_tag :span, str.lookup(locale), class: [:label, "label-#{css_class[str]}"]
  end

  def input24
    {input_html: {class: :span24}}
  end

  def tb_btn_class(cond)
    {
      true  => 'btn-primary',
      false => 'btn-default'
    }[cond]
  end

  def index_table_class
    %W[table table-striped table-hover table-condensed listing-table]
  end

  def content_table_class
    %W[table table-striped table-hover table-condensed table-bordered]
  end

  def n2d(val)
    val.blank? ? '-' : val
  end

  def state_btn_color(state_event)
    case state_event.to_s
    when "reinstate"
      "btn-success"
    when "app_received", "confirm", "verify_contribution"
      "btn-info"
    when "cancel", "cooling_off", "surrender", "cooled_off", "lapse", "terminate"
      "btn-danger"
    end
  end

  def show?(view_action)
    if controller.controller_name == 'basic_plans'
      true
    elsif controller.controller_name == 'service_records'
      # TODO: revert 'false' after sr implemente
      case view_action
      when :modify_applicant then false
      when :display_fna then false
      end
    end
  end

  def surround_with_legend_box(caption, hide, &block)
    content = capture(&block)
    if hide
      content
    else
      content_tag(:div, class: 'legend-box') do
        content_tag(:div, caption, class: 'legend-box-label') + content
      end
    end
  end

  def surround_with_div(class_name, show, &block)
    content = capture(&block)
    if show
      content_tag(:div, class: class_name) do
        content
      end
    else
      content
    end
  end

  def plan_details(bp)
    [
      link_to(bp.product_name, bp.product),
      plan_contribution(bp)
    ].join('&nbsp;&nbsp;/&nbsp;&nbsp;')
  end

  def plan_contribution(bp)
    list  = [bp.contribute_currency, to_dollar(bp.plan_info.plan_contribution)]
    list += [t_option_str(:pay_mode, bp.pay_mode), n2d(bp.plan_term)] unless bp.single?

    list.join('&nbsp;/&nbsp;')
  end

  def objectize(object_name)
    object_name.gsub(/\[(.*?)(_attributes)?\]/) do |exp|
      ".#{$1}"
    end
  end

  def email_link(val)
    return '-' if val.blank?
    val.gsub(/\s+/, '').split(',').map do |email|
      content_tag(:a, email, href: "mailto: #{email}")
    end.join(", ").html_safe
  end

  def service_record_partial(type_id, type = nil)
    lookup_dir = type == ServiceRecord ? 'service_records/partials_for_sr' : 'service_records/partials'
    if lookup_context.exists?("sr_#{type_id}", lookup_dir, true)
      return "#{lookup_dir}/sr_#{type_id}"
    else
      nil
    end
  end

  def service_record_label_and_date(sr, bp)
    case sr.type_id
    when 1
      {date_label: 'Online App Submitted at', date_value: bp.submit_on}
    when 2
      {date_label: 'Online App Submitted at', date_value: bp.submit_on}
    when 3
      {date_label: 'Call Out Completed at',   date_value: bp.call_out_on}
    when 4
      {date_label: 'App Document Sent at',    date_value: bp.app_send_on}
    when 5
      {date_label: 'Signed Doc Received at',  date_value: bp.app_rec_on}
    else
      {date_label: 'Creation Date',           date_value: sr.created_on}
    end
  end

  def datetime_format(object)
    object.present? ? object.strftime("%Y-%m-%d %H:%M") : nil
  end

  def date_format(object)
    object.present? ? object.strftime("%Y-%m-%d") : nil
  end

  def service_record_badge(count)
    content_tag :span, count, class: :badge, style: "background-color: #{count > 0 ? '' : '#cccccc'}"
  end
end
