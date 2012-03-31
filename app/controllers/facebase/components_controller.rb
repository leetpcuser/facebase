module Facebase
  class ComponentsController < ApplicationController
    # GET /components
    # GET /components.json
    def index
      if params[:stream_id]
        @components = Component.where(:stream_id => params[:stream_id]).all
      else
        @components = Component.all
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @components }
      end
    end

    # GET /components/1
    # GET /components/1.json
    def show
      @component = Component.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @component }
      end
    end

    # GET /components/new
    # GET /components/new.json
    def new
      @component = Component.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @component }
      end
    end

    # GET /components/1/edit
    def edit
      @component = Component.find(params[:id])
      @template = Facebase::Email.load_template(
        @component.campaign.name,
        @component.stream.name,
        @component.name,
        "html.erb",
        true
      )

      @template_keys = @component.template_keys
    end


    def preview
      @component = Component.find(params[:id])

      Facebase::CoreMailer.template(
        {
          :headers => {},
          :template_values => template_value_sniffer,
          :to => "to@someemail.com",
          :from => "from@someemail.com",
          :reply_to => "reply_to@someemail.com",
          :subject => "test_subject",
          :composite_id => "testCompositeId",
          :text_erb => Facebase::Email.load_template(self.campaign.name, self.stream.name, self.name, "text", true) ,
          :html_erb => Facebase::Email.load_template(self.campaign.name, self.stream.name, self.name, "html", true),
          :email_service_provider => Facebase::EmailTemplate::MockEmailServiceProvider.new
        }
      )

      email = Facebase::Email.new_sniffer_mock(@component.campaign.name, @component.stream.name, @component.name)
      Facebase::CoreMailer.template(email, true)
      #render :text =>
    end

    # POST /components
    # POST /components.json
    def create
      @component = Component.new(params[:component])

      respond_to do |format|
        if @component.save
          format.html { redirect_to @component, notice: 'Component was successfully created.' }
          format.json { render json: @component, status: :created, location: @component }
        else
          format.html { render action: "new" }
          format.json { render json: @component.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /components/1
    # PUT /components/1.json
    def update
      @component = Component.find(params[:id])


      #respond_to do |format|
      #  if @component.update_attributes(params[:component])
      #    format.html { redirect_to @component, notice: 'Component was successfully updated.' }
      #    format.json { head :no_content }
      #  else
      #    format.html { render action: "edit" }
      #    format.json { render json: @component.errors, status: :unprocessable_entity }
      #  end
      #end
    end

    # DELETE /components/1
    # DELETE /components/1.json
    def destroy
      @component = Component.find(params[:id])
      @component.destroy

      respond_to do |format|
        format.html { redirect_to components_url }
        format.json { head :no_content }
      end
    end
  end
end
