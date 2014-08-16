class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # FIXME: release when user session is ready
  # before_action :authenticate_user!

  before_action do
    resource = controller_name.singularize.to_sym
    method   = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def collection_paginate(instance_name: collection_instance_name, listing_scope: :index_listing, scope_param: false)
    per_page = params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : PER_PAGE
    page     = params[:page]     && params[:page].to_i > 0     ? params[:page].to_i     : 1

    obj = instance_variable_get(instance_name)

    params[:search].each do |k, v|
      k = "search_#{k}"
      obj = obj.send(k, v) if obj.respond_to?(k)
    end if params[:search] && params[:search].is_a?(Hash)

    if obj.respond_to?(listing_scope)
      if scope_param
        obj = obj.send(listing_scope, *scope_param)
      else
        obj = obj.send(listing_scope)
      end
    end

    # response.headers['total'] = "#{obj.count}"
    instance_variable_set(
      instance_name,
      obj.paginate(page: page, per_page: per_page).order(sort_column + " " + sort_direction)
    )
  end
end
