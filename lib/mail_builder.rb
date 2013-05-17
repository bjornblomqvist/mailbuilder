# encoding: utf-8

require 'action_view'
require 'mail'
require 'nokogiri'

class MailBuilder
  
  def initialize(identifier_or_path,with_images = true)
    if identifier_or_path.is_a?(Symbol)
      @path = "./app/emails/#{identifier_or_path.to_s}" 
    else
      @path = identifier_or_path
    end
    @basename = File.basename(@path)
    @with_images = with_images
  end
  
  def build(locals)
    result = nil
    builder = self
    Dir.chdir @path do
      result = Mail.new do

        part :content_type => 'multipart/related' do |related|
          
          related.part :content_type => 'multipart/alternative' do |alternative|
            alternative.part :content_type => 'text/plain', :body => builder.read_file_or_template("#{@basename}.txt", locals)
            alternative.part :content_type => 'text/html', :body => nil
          end
          
          builder.add_html_part(related,locals)
          
        end
      end
      
      result
    end
  end
  
  def add_inline_images doc,related
    
    parts = Hash.new
    
    # Add images for img elements
    doc.css('img').each do |img|
      unless parts[img['src']]
        related.add_file img['src']
        parts[img['src']] = related.parts[-1]
        related.parts[-1].encoded
      end
      img['src'] = "cid:#{parts[img['src']].content_id[1...-1]}"
    end
  
    # Add images for bgimage attributes
    doc.css('*[bgimage]').each do |element|
      unless parts[element['bgimage']]
        related.add_file element['bgimage']
        parts[element['bgimage']] = related.parts[-1]
        related.parts[-1].encoded
      end
      element['bgimage'] = "cid:#{parts[element['bgimage']].content_id[1...-1]}"
    end
  
    # Add images for background attribute
    doc.css('*[background]').each do |element|
      if(element['background'].match ".jpg|.png|.gif")
        unless parts[element['background']]
          related.add_file element['background']
          parts[element['background']] = related.parts[-1]
          related.parts[-1].encoded
        end
        element['background'] = "cid:#{parts[element['background']].content_id[1...-1]}"
      end
    end
  
    # Add style attributes with urls to an image
    doc.css('*[style]').each do |element|
    
      if(element['style'].match(/url\(["']?(.*?\.(png|gif|jpg|jpeg))["']?\)/i))
        file_name = element['style'].match(/url\(["']?(.*?\.(png|gif|jpg|jpeg))["']?\)/i)[1]
        unless parts[file_name]
          related.add_file file_name
          parts[file_name] = related.parts[-1]
          related.parts[-1].encoded
        end
      
        element['style'] = element['style'].gsub(file_name,"cid:#{parts[file_name].content_id[1...-1]}")
      end
    end
  end
  
  def add_html_part related,locals
    
    doc = Nokogiri::HTML::fragment(read_file_or_template("#{@basename}.html", locals))
    
    add_inline_images(doc,related) if @with_images
    
    related.parts[0].parts[1].content_type ['text', 'html', { 'charset' => 'UTF-8' }]
    related.parts[0].parts[1].body = doc.to_s
    
  end
  
  def read_file_or_template(filename, locals = {})
    if File.exists?(filename)
      File.read(filename)
    elsif File.exists?("#{filename}.erb")
      template = ERB.new(File.read("#{filename}.erb"))
      template.result(erb_binding(locals))
    end
  end
  
  module SimpleRenderingHelper

    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::SanitizeHelper

    def self.included(into)
      into.class_eval do
        extend ActionView::Helpers::SanitizeHelper::ClassMethods
      end
    end

  end
  
  class BindingHelper
    include SimpleRenderingHelper
    def binding_for
      binding
    end
    
    def add_attribute key,value
      self.class.__send__(:attr_accessor, "#{key}")
      self.__send__("#{key}=", value)
    end
    
    def set_locals hash
      hash.each do |key,value|
        add_attribute(key,value)
      end
    end
  end
  
  
  def erb_binding(vars)
    object = BindingHelper.new
    object.set_locals(vars)
    object.binding_for
  end
  
end
