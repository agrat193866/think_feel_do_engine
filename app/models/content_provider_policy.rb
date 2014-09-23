# Extends BitCore::ContentProvider with additional properties.
class ContentProviderPolicy < ActiveRecord::Base
  belongs_to :content_provider,
             foreign_key: :bit_core_content_provider_id,
             class_name: "BitCore::ContentProvider"
end
