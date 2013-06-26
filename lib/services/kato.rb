class Service::Kato < Service::Base
  title "Kato"
  string :url, :placeholder => "https://api.kato.im/rooms/123",
         :label => 'Enter Crashlytics webhook URL from the Integrations tab in room settings in your <a href="https://kato.im" target="_blank">Kato</a> account'
  page "Crashlytics webhook URL", [ :url ]

  # Create an issue
  def receive_issue_impact_change(config, payload)
    ok = post_event(config[:url], 'issue_impact_change', 'issue', payload)
    raise "Kato Issue Create Failed: #{ payload }" unless ok
    # return :no_resource if we don't have a resource identifier to save
    :no_resource
  end

  def receive_verification(config, _)
    success = [true,  "Success. Verification message should be already in chat room."]
    failure = [false, "Oops! Is webhook url correct?"]
    ok = post_event(config[:url], 'verification', 'none', nil)
    ok ? success : failure
  rescue => e
    log "Rescued a verification error in kato: (url=#{config[:url]}) #{e}"
    failure
  end

  private
  def post_event(url, event, payload_type, payload)
    body = {
      :event        => event,
      :payload_type => payload_type }
    body[:payload]  =  payload if payload

    resp = http_post url do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body                    = body.to_json
    end
    ok = resp.status == 200
    log "HTTP Error: status code: #{ resp.status }, body: #{ resp.body }" unless ok
    ok
  end
end
