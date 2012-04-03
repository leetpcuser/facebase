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
      template_values = params[:template_values]
      template_content = params[:template_content]
      subject_line = params[:subject_line]

      email = Facebase::CoreMailer.template(
        {
          :headers => {},
          :template_values => template_values,
          :to => "to@someemail.com",
          :from => "from@someemail.com",
          :reply_to => "reply_to@someemail.com",
          :subject => subject_line,
          :composite_id => "testCompositeId",
          :text_erb => "",
          :html_erb => template_content,
          :email_service_provider => Facebase::EmailTemplate::MockEmailServiceProvider.new
        }
      )

      render :text => email.html_part.body.to_s
    end


    def litmus_preview
      esp = Facebase::EmailServiceProvider.first
      raise "No Email Service providers installed" if esp.blank?
      raise "Litmus static email not specified" if Facebase.litmus_static_email.blank?

      template_values = params[:template_values]
      template_content = params[:template_content]
      subject_line = params[:subject_line]

      email = Facebase::CoreMailer.template(
        {
          :headers => {},
          :template_values => template_values,
          :to => Facebase.litmus_static_email,
          :from => "from@facebase.com",
          :reply_to => "reply_to@facebase.com",
          :subject => subject_line,
          :composite_id => "testCompositeId",
          :text_erb => "",
          :html_erb => template_content,
          :email_service_provider => esp
        }
      )

      email.deliver
      head 200
    end

    def direct_preview
      esp = Facebase::EmailServiceProvider.first
      raise "No Email Service providers installed" if esp.blank?

      template_values = params[:template_values]
      template_content = params[:template_content]
      subject_line = params[:subject_line]
      email_address = params[:email_address]


      email = Facebase::CoreMailer.template(
        {
          :headers => {},
          :template_values => template_values,
          :to => email_address,
          :from => "from@facebase.com",
          :reply_to => "reply_to@facebase.com",
          :subject => subject_line,
          :composite_id => "testCompositeId",
          :text_erb => "",
          :html_erb => template_content,
          :email_service_provider => esp
        }
      )

      email.deliver
      head 200
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

      respond_to do |format|
        if @component.update_attributes(params[:component])

          # Save to s3, we have S3 should have turned on to prevent dataloss
          @component.save_template_content(params[:template_content])

          format.html { redirect_to @component, notice: 'Component was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @component.errors, status: :unprocessable_entity }
        end
      end
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
