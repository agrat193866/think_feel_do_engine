# Think Feel Do Engine

[![Build Status](https://travis-ci.org/cbitstech/think_feel_do_engine.svg)](https://travis-ci.org/cbitstech/think_feel_do_engine) [![security](https://hakiri.io/github/cbitstech/think_feel_do_engine/master.svg)](https://hakiri.io/github/cbitstech/think_feel_do_engine/master)

Provides the tools and administrative interface for Think Feel Do.

## Installation

To add to a host Rails application, add to the `Gemfile`

    gem "think_feel_do_engine", git: "git@github.com:cbitstech/think_feel_do_engine.git"

then install

    bundle install

mount the routes within `config/routes.rb`

    Rails.application.routes.draw do
      mount ThinkFeelDoEngine::Engine => ""
    end


Install the think_feel_do_engine's migrations into the host application and migrate:
```console
rake think_feel_do_engine:install:migrations
rake db:migrate
```

Add correct arm association to the Tool in ```config/initializers/tools.rb```
```ruby
require File.expand_path("../../app/models/bit_core/tool",
                         BitCore::Engine.called_from)

# Extend BitCore::Tool model.
module BitCore
  class Tool
    belongs_to :arm,
               class_name: "Arm"

    validates :arm_id, presence: true
  end
end
```

Add correct arm association and validations to the Tool class in ```config/initializers/bit_core/tools.rb```
```ruby
require File.expand_path("../../app/models/bit_core/tool",
                         BitCore::Engine.called_from)

# Extend BitCore::Tool model.
module BitCore
  class Tool
    belongs_to :arm
    validates :arm_id, presence: true

    validates :position,
              uniqueness: true,
              numericality: { greater_than_or_equal_to: 0 },
              uniqueness: { scope: :arm_id }
  end
end
```

Add correct arm association and validations to the Slideshow class in ```config/initializers/bit_core/slideshows.rb```

```ruby
require File.expand_path("../../app/models/bit_core/slideshow",
                         BitCore::Engine.called_from)

# Extend BitCore::Slideshow model.
module BitCore
  class Slideshow
    belongs_to :arm
    validates :arm_id, presence: true
  end
end
```

## Run specs

Set up the database

    rake app:db:create app:db:migrate

run the specs

    rake spec

