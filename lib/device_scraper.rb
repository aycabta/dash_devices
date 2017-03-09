require 'mechanize'
require 'uri'

class DeviceScraper
  def initialize(device_model)
    @device_model = device_model
  end

  def run
    agent = Mechanize.new
    agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36'
    page = agent.get(oauth_url)
    form = page.form_with(name: 'signIn', id: 'ap_signin_form') { |f|
      f.email = Rails.application.secrets.amazon_email
      f.password = Rails.application.secrets.amazon_password
      f.checkbox_with(name: 'rememberMe').check
    }
    loggedin = form.submit

    form = loggedin.form_with(name: 'consent-form')
    okey = form.button_with(name: 'consentApproved')
    choose = form.click_button(okey)

    slot_set = recursive_choose(choose)
    slot_set
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

  def oauth_url
    redirect_uri = "http://localhost:55582/"
    base = 'https://www.amazon.com/ap/oa?'
    client_id = Rails.application.secrets.client_id
    serial = generate_serial
    params = {
      client_id: client_id,
      scope: 'dash:replenish',
      response_type: 'code',
      redirect_uri: URI.encode_www_form_component(redirect_uri),
      scope_data: %Q`{"dash:replenish":{"device_model":"#{@device_model}","serial":"#{serial}"#{ ',"is_test_device":true' if @is_test }}}`.gsub('"', '%22')
    }
    "#{base}#{params.map{ |k, v| "#{k}=#{v}" }.join(?&)}"
  end

  def generate_serial
    orig = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
    random_suffix = (0...16).map { orig[rand(orig.size)] }.join
    "#{@device_model}_#{Time.now.to_i}_#{random_suffix}"
  end
end
