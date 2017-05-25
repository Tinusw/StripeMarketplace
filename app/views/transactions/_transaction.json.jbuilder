json.extract! transaction, :id, :description, :user_id, :merchant_id, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
