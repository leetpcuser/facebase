module Facebase
  class ShardsController < ApplicationController
    before_filter :authenticate_admin!
    # GET /shards
    # GET /shards.json
    def index
      @shards = Shard.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @shards }
      end
    end

    # GET /shards/1
    # GET /shards/1.json
    def show
      @shard = Shard.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @shard }
      end
    end

    # GET /shards/new
    # GET /shards/new.json
    def new
      @shard = Shard.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @shard }
      end
    end

    # GET /shards/1/edit
    def edit
      @shard = Shard.find(params[:id])
    end

    # POST /shards
    # POST /shards.json
    def create
      @shard = Shard.new(params[:shard])

      respond_to do |format|
        if @shard.save
          format.html { redirect_to @shard, notice: 'Shard was successfully created.' }
          format.json { render json: @shard, status: :created, location: @shard }
        else
          format.html { render action: "new" }
          format.json { render json: @shard.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /shards/1
    # PUT /shards/1.json
    def update
      @shard = Shard.find(params[:id])

      respond_to do |format|
        if @shard.update_attributes(params[:shard])
          format.html { redirect_to @shard, notice: 'Shard was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @shard.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /shards/1
    # DELETE /shards/1.json
    def destroy
      @shard = Shard.find(params[:id])
      @shard.destroy

      respond_to do |format|
        format.html { redirect_to shards_url }
        format.json { head :no_content }
      end
    end
  end
end
