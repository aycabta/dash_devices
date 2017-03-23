require 'mechanize'
require 'uri'

class DeviceScraper
  @@cookies_for_scrape = "#{Rails.root}/tmp/cookies_for_scrape"

  def initialize(device_model)
    @device_model = device_model
  end

  def run
    agent = Mechanize.new
    load_cookies(agent)
    agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36'
    url, params = oauth_request_info
    page = agent.get(url, params)
    form = page.form_with(name: 'signIn', id: 'ap_signin_form') { |f|
      f.email = Rails.application.secrets.amazon_email
      f.password = Rails.application.secrets.amazon_password
      f.checkbox_with(name: 'rememberMe').check
    }
    loggedin = form.submit

    form = loggedin.form_with(name: 'consent-form')
    okey = form.button_with(name: 'consentApproved')
    choose = form.click_button(okey)

    save_cookies(agent)

    slot_set = recursive_choose(choose)
    slot_set
  end

  def save_cookies(agent)
    io = StringIO.new('', 'r+')
    agent.cookie_jar.save(io)
    open(@@cookies_for_scrape, 'w') do |f|
      f.write(io.string)
    end
  end

  def load_cookies(agent)
    if File.exist?(@@cookies_for_scrape)
      open(@@cookies_for_scrape, 'r') do |f|
        io = StringIO.new(f.read, 'r')
        agent.cookie_jar.clear
        agent.cookie_jar.load(io)
      end
    end
  end

  def recursive_choose(choose)
    title = choose.search('.header').search('.title').search('span').attr('title').value
    slot_id = choose.search('//input[@name="slotId"]').attr('value').value
    items = choose.search('.a-row .products').first.search('.product')
    asin_list = items.map { |i| i.attributes['id'].value }

    form = choose.form_with(action: '/slot_action')
    form.radiobutton_with(name: 'asin', value: asin_list.first).check
    next_button = form.button_with(class: 'a-button-input')
    choose = form.click_button(next_button)
    data = {
      slot_id: slot_id,
      asin_list: asin_list,
      title: title
    }
    if choose.uri.to_s != 'https://drs-web.amazon.com/setup_overview'
      recursive_choose(choose).push(data)
    else
      [data]
    end
  end

  def oauth_request_info
    base = 'https://www.amazon.com/ap/oa?'
    params = {
      client_id: Rails.application.secrets.amazon_client_id,
      scope: 'dash:replenish',
      response_type: 'code',
      redirect_uri: 'http://localhost:3000/',
      scope_data: %Q`{"dash:replenish":{"device_model":"#{@device_model}","serial":"#{generate_serial}","is_test_device":true}}`
    }
    [base, params]
  end

  def generate_serial
    orig = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
    random_suffix = (0...16).map { orig[rand(orig.size)] }.join
    "#{@device_model}_#{Time.now.to_i}_#{random_suffix}"
  end
end
