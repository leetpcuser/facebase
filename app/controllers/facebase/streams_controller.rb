module Facebase
  class StreamsController < ApplicationController
    before_filter :authenticate_admin!

    # GET /streams
    # GET /streams.json
    def index
      if session[:campaign_id]
        @campaign_id = session[:campaign_id]
        @streams = Stream.where(:campaign_id => @campaign_id).all

        @campaign = Campaign.find(@campaign_id)
        @breadcrumbs = [{"link" => "#", "name" => @campaign.name}]
      else
        @streams = Stream.all
      end


      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @streams }
      end
    end

    # GET /streams/1
    # GET /streams/1.json
    def show
      @stream = Stream.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @stream }
      end
    end

    # GET /streams/new
    # GET /streams/new.json
    def new
      @stream = Stream.new
      @stream.campaign_id = session[:campaign_id] if session[:campaign_id]


      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @stream }
      end
    end

    # GET /streams/1/edit
    def edit
      @stream = Stream.find(params[:id])
    end

    # POST /streams
    # POST /streams.json
    def create
      @stream = Stream.new(params[:stream])

      respond_to do |format|
        if @stream.save
          format.html { redirect_to @stream, notice: 'Stream was successfully created.' }
          format.json { render json: @stream, status: :created, location: @stream }
        else
          format.html { render action: "new" }
          format.json { render json: @stream.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /streams/1
    # PUT /streams/1.json
    def update
      @stream = Stream.find(params[:id])

      respond_to do |format|
        if @stream.update_attributes(params[:stream])
          format.html { redirect_to @stream, notice: 'Stream was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @stream.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /streams/1
    # DELETE /streams/1.json
    def destroy
      @stream = Stream.find(params[:id])
      @stream.destroy

      respond_to do |format|
        format.html { redirect_to streams_url }
        format.json { head :no_content }
      end
    end
  end
end
