module SocialNetworking
  class Goal
    attr_reader :completed_at,
                :created_at,
                :deleted_at,
                :description,
                :due_on,
                :comments

    def self.where(query_contents)
      SocialNetworking::Goal
    end

    def self.each
      SocialNetworking::Goal
    end

    def self.count
      1
    end
  end
end
