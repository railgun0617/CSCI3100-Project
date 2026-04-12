require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user, :staff) }

  it "successfully connects with a verified user" do
    connect "/cable", env: { "warden" => double(user: user) }

    expect(connection.current_user).to eq(user)
  end

  it "rejects connection without a user" do
    expect {
      connect "/cable", env: { "warden" => double(user: nil) }
    }.to have_rejected_connection
  end
end
