FactoryBot.define do
  factory :player do
    username { "TestPlayer#{rand(1000)}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    blood_pool { 5000 }
    story_progression { 0 }
    is_guest { false }
  end

  factory :guest_player, parent: :player do
    username { nil }
    password { nil }
    password_confirmation { nil }
    is_guest { true }
  end
end
