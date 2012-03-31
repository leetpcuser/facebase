require 'uri'

module Facebase
  module CoreMailerHelper

    # Support for link clicks.
    def track_link(*args, &block)
      @_track_count ||= 0
      if block_given?
        options = args.first || {}
        html_options = args.second
        track_link(capture(&block), options, html_options)
      else
        @_track_count += 1
        name = args[0]
        options = args[1] || {}
        html_options = args[2]

        html_options = convert_options_to_data_attributes(options, html_options)
        url = url_for(options)

        href = html_options['href']
        tag_options = tag_options(html_options)

        # Inject our tracking url, and pass in the redirect_url
        hash = {
          :controller => "facebase/tracking",
          :action => :link,
          :url => url,
          :only_path => false,
          :host => Facebase.tracker_host,
          :n => @_track_count,
          :com_id => @_composite_id
        }

        url = url_for(hash)
        # End injection

        href_attr = "href=\"#{ERB::Util.html_escape(url)}\"" unless href
        "<a #{href_attr}#{tag_options}>#{ERB::Util.html_escape(name || url)}</a>".html_safe
      end
    end


    # Provides the link to the unsubscribe action on the mailspy servers
    def unsubscribe_url
      url_for(
        :controller => "facebase/tracking",
        :action => :unsubscribe,
        :com_id => @_composite_id,
        :only_path => false,
        :host => Facebase.tracker_host
      )
    end


    # Support for open tracking, client support, etc
    def tracking_bug
      url = url_for(
        :controller => "facebase/tracking",
        :action => :bug,
        :com_id => @_composite_id,
        :only_path => false,
        :host => Facebase.tracker_host
      )
      "<img src='#{url}' style='display:none' width='1' height='1' border='0' />".html_safe
    end

  end
end
