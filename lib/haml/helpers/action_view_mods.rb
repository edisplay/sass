begin
  require 'rubygems'
  require 'active_support'
  require 'action_view'
  action_view_included = true
rescue LoadError
  action_view_included = false
end

if action_view_included
  class ActionView::Base
    alias_method :old_concat, :concat unless instance_methods.include? "old_concat"
    alias_method :old_form_tag, :form_tag unless instance_methods.include? "old_form_tag"
  end
  
  module Haml
    module Helpers
      # This module overrides various helpers in ActionView to make them
      # work more effectively with Haml. It's not available unless ActionView
      # is installed.
      module ActionViewMods
        def self.included(othermod)
          othermod.action_view(true)
        end
        
        def concat(string, binding = nil)
          buffer.buffer.concat(string)
        end
        
        def form_tag(url_for_options = {}, options = {}, *parameters_for_url, &proc)
          if block_given?
            oldproc = proc 
            proc = bind_proc do |*args|
              concat "\n"
              tab_up
              oldproc.call(*args)
              tab_down
            end
          end
          old_form_tag(url_for_options, options, *parameters_for_url, &proc)
        end
      end
    end
  end
end

