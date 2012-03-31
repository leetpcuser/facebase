module Facebase
  class EmailServiceProvidersController < ApplicationController
    before_filter :authenticate_admin!
    # GET /email_service_providers
    # GET /email_service_providers.json
    def index
      @email_service_providers = EmailServiceProvider.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @email_service_providers }
      end
    end

    # GET /email_service_providers/1
    # GET /email_service_providers/1.json
    def show
      @email_service_provider = EmailServiceProvider.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @email_service_provider }
      end
    end

    # GET /email_service_providers/new
    # GET /email_service_providers/new.json
    def new
      @email_service_provider = EmailServiceProvider.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @email_service_provider }
      end
    end

    # GET /email_service_providers/1/edit
    def edit
      @email_service_provider = EmailServiceProvider.find(params[:id])
    end

    # POST /email_service_providers
    # POST /email_service_providers.json
    def create
      @email_service_provider = EmailServiceProvider.new(params[:email_service_provider])

      respond_to do |format|
        if @email_service_provider.save
          format.html { redirect_to @email_service_provider, notice: 'Email service provider was successfully created.' }
          format.json { render json: @email_service_provider, status: :created, location: @email_service_provider }
        else
          format.html { render action: "new" }
          format.json { render json: @email_service_provider.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /email_service_providers/1
    # PUT /email_service_providers/1.json
    def update
      @email_service_provider = EmailServiceProvider.find(params[:id])

      respond_to do |format|
        if @email_service_provider.update_attributes(params[:email_service_provider])
          format.html { redirect_to @email_service_provider, notice: 'Email service provider was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @email_service_provider.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /email_service_providers/1
    # DELETE /email_service_providers/1.json
    def destroy
      @email_service_provider = EmailServiceProvider.find(params[:id])
      @email_service_provider.destroy

      respond_to do |format|
        format.html { redirect_to email_service_providers_url }
        format.json { head :no_content }
      end
    end
  end
end
