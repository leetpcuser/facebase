module Facebase
  class ContactsController < ApplicationController
    before_filter :authenticate_admin!
    # GET /contacts
    # GET /contacts.json
    def index
      @contacts = []
      Facebase::Contact.on_each_shard{|p|
        @contacts.concat(p.limit(20).all())
      }
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contacts }
      end
    end

    # GET /contacts/search
    # GET /contacts/search.json
    def email_search
      @contacts = []
      @search = params[:search]
      Facebase::Contact.on_each_shard{|p|
        if @search && !@search[:email].nil?
          @contacts.concat(p.limit(20).where("email_address like ?",'%' + @search[:email] + '%'))
        else
          @contacts.concat(p.limit(20).all())
        end
      }
      respond_to do |format|
        format.html { render "/facebase/contacts/index.html.erb" }
        format.json { render json: @contacts }
      end
    end


    # GET /contacts/1
    # GET /contacts/1.json
    def show
      contact_shard = Facebase::Contact.shard_for(params[:id])
      @contact = contact_shard.where("profile_id = ? ", params[:id]).includes(:profile, :events, :emails).first

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contact }
      end
    end

    # GET /contacts/new
    # GET /contacts/new.json
    def new
      @contact = Contact.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contact }
      end
    end

    # GET /contacts/1/edit
    def edit
      @contact = Contact.find(params[:id])
    end

    # POST /contacts
    # POST /contacts.json
    def create
      @contact = Contact.new(params[:contact])

      respond_to do |format|
        if @contact.save
          format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
          format.json { render json: @contact, status: :created, location: @contact }
        else
          format.html { render action: "new" }
          format.json { render json: @contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /contacts/1
    # PUT /contacts/1.json
    def update
      @contact = Contact.find(params[:id])

      respond_to do |format|
        if @contact.update_attributes(params[:contact])
          format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contact.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /contacts/1
    # DELETE /contacts/1.json
    def destroy
      @contact = Contact.find(params[:id])
      @contact.destroy

      respond_to do |format|
        format.html { redirect_to contacts_url }
        format.json { head :no_content }
      end
    end
  end
end
