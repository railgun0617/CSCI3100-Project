class Equipment < ApplicationRecord
    belongs_to :tenant, optional: true
end
