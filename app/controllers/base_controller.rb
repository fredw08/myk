class BaseController < ApplicationController
  helper_method :resource_name, :resource_class, :resource_instance, :collection_instance

  load_and_authorize_resource

  def index
    collection_paginate
  end

  def create
    obj = resource_instance
    respond_to do |fmt|
      if obj.save
        fmt.html { redirect_to resource_instance, notice: "#{resource_class.name.titleize} was created" }
      else
        fmt.html { render :new }
      end
    end
  end

  def update
    obj = resource_instance
    respond_to do |fmt|
      if obj.update(send("#{resource_name}_params"))
        fmt.html { redirect_to resource_instance, notice: "#{resource_class.name.titleize} was updated" }
      else
        fmt.html { render :edit }
      end
    end
  end

  def destroy
    obj = resource_instance
    respond_to do |fmt|
      if obj.destroy
        fmt.html { redirect_to polymorphic_url(obj.class), notice: "#{resource_class.name.titleize} was deleted." }
      else
        fmt.html { redirect_to obj, alert: "#{resource_class.name.titleize} can't be deleted." }
      end
    end
  end

  private

  def resource_name
    @resource_name ||= controller_name.singularize.downcase.to_sym
  end

  def resource_class
    resource_instance.class
  end

  def collection_instance_name
    @collection_instance_name ||= "@#{controller_name.downcase}".to_sym
  end

  def resource_instance
    instance_variable_get("@#{resource_name}".to_sym)
  end

  def resource_instance=(instance)
    instance_variable_set("@#{resource_name}".to_sym, instance)
  end

  def collection_instance
    instance_variable_get(collection_instance_name)
  end

  def collection_instance=(instance)
    instance_variable_set(collection_instance_name, instance)
  end

  def sort_column
    @default_sort_column ||= 1
    params[:sort] || @default_sort_column.to_s
  end

  def sort_direction
    @default_sort_direction ||= 'asc'
    %W[asc desc].include?(params[:dir]) ? params[:dir] : @default_sort_direction
  end
end
