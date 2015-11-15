json.array!(@events_users) do |events_user|
  json.extract! events_user, :id
  json.url events_user_url(events_user, format: :json)
end
