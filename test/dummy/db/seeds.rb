# Deletes all the test data first
Facebase::Profile0.delete_all
Facebase::Contact0.delete_all
Facebase::Email0.delete_all
Facebase::Shard.delete_all

3.times do |i|
  Facebase::Shard.create(
    initialized: true,
    host: "127.0.0.1",
    socket: "",
    adapter: "mysql2",
    username: "root",
    password: "",
    database: "facebase#{ i + 1 }",
    port: nil,
    pool: 5,
    encoding: "utf8",
    reconnect: true,
    principle_model: "profile"
  )
end


# creates a single profile, with some contacts and a couple emails
profile = Facebase::Profile0.create!(
  {
    facebook_id: 203810,
    name: "First Last",
    first_name: "First",
    last_name: "Last",
    birth_year: 1987,
    birth_month: 9,
    birth_day_of_month: 26,
    gender: "female",
    relationship_status: "Married",
    religion: nil,
    political: nil,
    timezone: nil,
    locale: "en_US",
    hometown: nil,
    location: nil,
  })

contact = Facebase::Contact0.create!(
  {
    profile_id: profile.id,
    facebook_id: 203810,
    email_address: "email",
    phone: nil,
    purchase_total: nil,
    purchase_count: 0,
    unsubscribe_phone: false,
    unsubscribe_facebook: false,
    unsubscribed_email: false,
    invalid_email: false,
    spam_email: false,
    bounced_email: true,
    emails_delivered: 0,
    times_emails_opened: 0,
    times_emails_clicked: 0,
    last_contacted_at: "2012-03-11 09:46:19"
  }
)

10.times do |i|
  contact.emails.create!(
    to: "something@sbcglobal.net",
    from: "susan@davia.com",
    subject: "Put a decadent twist in a traditional St Patrick's ...",
    reply_to: "susan@davia.com",
    headers: {},
    template_values: {},
    email_service_provider_id: 1,
    campaign: "2012-st-pattys",
    stream: "a-first-touch",
    component: "pattys_a",
    schedule_at: Time.now,
    pruned: false,
    locked: false,
    sent: (i % 2 == 0),
    failed: false,
    error_message: nil,
    error_backtrace: nil,
    utm_source: "mailspy",
    utm_medium: "email",
    utm_campaign: (i % 4 == 0) ? "2012-st-pattys" : "2012-easter",
    utm_term: "a-first-touch",
    utm_content: nil
  )
end

