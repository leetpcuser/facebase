namespace :create do

  task :user => :environment do
    profile = Facebase::Profile.balanced_shard.create!(
      :facebook_id => 214367,
      :name => "Timothy Cardenas",
      :first_name => "Timothy",
      :last_name => "Cardenas"
    )
    profile.create_contact!(
      :email_address => "trcarden@gmail.com"
    )

    Facebase::Profile1.create(
            :facebook_id => 713048136,
            :name=>"Logan Deans",
            :first_name=>"Logan",
            :last_name=>"Deans",
            :contact => Facebase::Contact1.create(
                    :email_address => "logandeans@gmail.com"
            )
    )
    Facebase::Profile1.create(
            :facebook_id => 100003036265740,
            :name=>"Sam Gong",
            :first_name=>"Sam",
            :last_name=>"Gong",
            :contact => Facebase::Contact1.create(
                    :email_address => "sam@dextropy.com"
            )
    )
    Facebase::Profile2.create(
            :facebook_id => 100003040855693,
            :name=>"Hugo Hipster",
            :first_name=>"Hugo",
            :last_name=>"Hipster",
            :contact => Facebase::Contact2.create(
                    :email_address => "hopeforhipsters@gmail.com"
            )
    )
    Facebase::Profile3.create(
            :facebook_id => 100003034569360,
            :name=>"Joe Johnson",
            :first_name=>"Joe",
            :last_name=>"Johnson",
            :contact => Facebase::Contact3.create(
                    :email_address => "trcarden@davia.com"
            )
    )
    Facebase::Profile3.create(
            :facebook_id => 100000634013200,
            :name=>"Eva Deans",
            :first_name=>"Eva",
            :last_name=>"Deans",
            :contact => Facebase::Contact3.create(
                    :email_address => "evadeans@gmail.com"
            )
    )

  end

  task :emails => :environment do

    # Clear all the emails for multiple runs
    Facebase::Email.on_each_shard { |s| s.delete_all }

    profile = nil
    Facebase::Profile.on_each_shard do |shard|
      potential = shard.where(:facebook_id => 214367).first
      unless potential.nil?
        profile = potential
        break
      end
    end

    raise "Call create:user before creating emails" if profile.blank?
    contact = profile.contact


    # create that bad mother
    email = contact.emails.create(
      :campaign => "2012-st-pattys",
      :stream => "a-first-touch",
      :component => "pattys_a",
      :schedule_at => Time.now.to_i,
      :subject => "Test Email",
      :template_values => {},
      :from => "reminder@davia.com",
      :reply_to => "reminder@davia.com",
      :email_service_provider_id => Facebase::EmailServiceProvider.first.id
    )

    # Try to send it!
    email.deliver

  end

end
