# Allows for extending BitCore::ContentProvider with an additional model class
# and corresponding attributes.
class ContentProviderDecorator
  # Play nicely with form_for.
  include ActiveModel::Conversion

  delegate :id, :bit_core_content_module_id, :type, :source_content,
           :source_content_type, :source_content_id, :position,
           :show_next_nav, :pretty_label, :content_module,
           :template_path, :locals, :data_attributes,
           to: :content_provider
  delegate :is_skippable_after_first_viewing,
           to: :content_policy

  attr_reader :content_provider, :content_policy

  def self.fetch(provider_or_id)
    provider = provider_or_id
    if provider.try(:to_i).class == Fixnum
      provider = BitCore::ContentProvider.find(provider.to_i)
    end
    policy = ContentProviderPolicy.find_or_initialize_by(
      bit_core_content_provider_id: provider.id
    )

    new(content_provider: provider, content_policy: policy)
  end

  # Play nicely with form_for.
  def self.model_name
    ActiveModel::Name.new(BitCore::ContentProvider)
  end

  # Eagerly load BitCore::ContentProvider descendants, as would
  # normally be required in development and test environments.
  def self.content_provider_classes
    BitCore::ContentProviders::SlideshowProvider.to_s
    Dir["#{Rails.root}/app/models/content_providers/*.rb"].each do |file|
      require_dependency file
    end

    BitCore::ContentProvider.descendants
  end

  def initialize(attrs = {})
    if attrs[:content_provider] && attrs[:content_policy]
      @content_provider = attrs[:content_provider]
      @content_policy = attrs[:content_policy]
    else
      provider_attrs = content_provider_attributes(attrs)
      @content_provider = BitCore::ContentProvider.new(provider_attrs)
      policy_attrs = content_policy_attributes(attrs)
      @content_policy = ContentProviderPolicy.new(policy_attrs)
    end
  end

  # Play nicely with form_for.
  def to_model
    content_provider
  end

  # Play nicely with form_for.
  def persisted?
    true
  end

  def errors
    OpenStruct.new(full_messages: content_provider.errors.full_messages +
                   content_policy.errors.full_messages)
  end

  def save
    content_provider.transaction do
      content_provider.save!
      content_policy.bit_core_content_provider_id = content_provider.id
      content_policy.save!
    end

    true

  rescue
    false
  end

  def update(attrs)
    provider_attrs = content_provider_attributes(attrs)
    policy_attrs = content_policy_attributes(attrs)

    content_provider.update(provider_attrs) &&
      content_policy.update!(policy_attrs)
  end

  def destroy
    content_provider.transaction do
      content_policy.destroy!
      content_provider.destroy!
    end

    true

  rescue
    false
  end

  def content_provider_attributes(attrs)
    attrs.slice(
      :bit_core_content_module_id, :type, :source_content_type,
      :source_content_id, :position, :show_next_nav, :template_path
    )
  end

  def content_policy_attributes(attrs)
    attrs.slice(:is_skippable_after_first_viewing)
  end
end
