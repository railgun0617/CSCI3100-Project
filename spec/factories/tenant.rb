FactoryBot.define do
  factory :tenant do
    sequence(:name) { |n| "Shaw College #{n}" }
    factory :admin_tenant do
      name { "Admin" }
    end

    factory :non_admin_tenant do
      sequence(:name) { |n| "Department of Computer Science and Engineering #{n}" }
    end
  end
end
