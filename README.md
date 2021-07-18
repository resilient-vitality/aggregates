<p align="center">
  <img src="aggregates.png" alt="Aggregates Icon"/>
</p>

# Aggregates

A ruby gem for writing CQRS applications with pluggable components.

_Warning:_ This Gem is in active development and probably doesn't work correctly. Tests are really light.

[![Gem Version](https://badge.fury.io/rb/aggregates.svg)](http://badge.fury.io/rb/aggregates)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://rubystyle.guide)

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Features](#features)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Usage](#usage)
    - [Defining AggregateRoots](#defining-aggregateroots)
    - [Creating Commands](#creating-commands)
    - [Creating Events](#creating-events)
    - [Processing Commands](#processing-commands)
    - [Value Objects](#value-objects)
    - [Filtering Commands](#filtering-commands)
    - [Processing Events](#processing-events)
    - [Executing Commands](#executing-commands)
    - [Auditing Aggregates](#auditing-aggregates)
    - [Configuring](#configuring)
      - [Storage Backends](#storage-backends)
        - [Dynamoid](#dynamoid)
      - [Adding Command Processors](#adding-command-processors)
      - [Adding Event Processors](#adding-event-processors)
      - [Adding Command Filters](#adding-command-filters)
  - [Development](#development)
  - [Tests](#tests)
  - [Versioning](#versioning)
  - [Code of Conduct](#code-of-conduct)
  - [Contributions](#contributions)
  - [License](#license)
  - [History](#history)
  - [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Features

- Pluggable Event / Command Storage Backends
- Tools for Command Validation, Filtering, and Execution.
- Opinionated structure for CQRS, Domain-Driven Design, and Event Sourcing.

## Requirements

1. [Ruby 3.0+](https://www.ruby-lang.org)

## Setup

To install, run:

    gem install aggregates

Or Add the following to your Gemfile:

    gem "aggregates"

## Usage

### Defining AggregateRoots

An AggregateRoot is a grouping of domain object(s) that work to encapsulate
a single part of your Domain or Business Logic. The general design of aggregate roots should be as follows:

- Create functions that encapsulate different operations on your Aggregate Roots. These functions should enforce business logic constraints and then capture state changes by creating events.
- Create event handlers that actually perform the state changes captured by those events.

A simple example is below:

```ruby
class Post < Aggregates::AggregateRoot
  # Write functions that encapsulate business logic.
  def publish(command)
    apply PostPublished, body: command.body, category: command.category
  end

  # Modify the state of the aggregate from the emitted events.
  on PostPublished do |event|
    @body = event.body
    @category = event.category
  end
end
```

_Note:_ the message-handling DSL (`on`) supports passing a super class of any given event
as well. Every `on` block that applies to the event will be called in order from most specific to least specific.

### Creating Commands

Commands are a type of domain message that define the shape and contract of data needed to perform an action. 
Essentially, they provide the api for interacting with your domain. 
Commands should have descriptive names capturing the change they are intended to make. 
For instance, `ChangeUserEmail` or `AddComment`.

```ruby
class PublishPost < Aggregates::Command
  interacts_with Post

  field :body, :category
  validates_length_of :body, minimum: 10
end
```

You can specify them via attr accessors and use `ActiveModel::Validations` to enforce data constraints. 

### Creating Events

An Event describes something that happened. They are named in passed tense.
For instance, if the user's email has changed, then you might create an event type called
`UserEmailChanged`.

```ruby
class PostPublished < Aggregates::Event
  field :body, :category
end
```

### Processing Commands

The goal of a `CommandProcessor` is to route commands that have passed validation and
filtering. They should invoke business logic on their respective aggregates. Doing so is accomplished by using the same message-handling DSL as in our `AggregateRoots`, this time for commands.

```ruby
class PostCommandProcessor < Aggregates::CommandProcessor
  # Instead of `process`, you may use `on`
  process PublishPost do |command, post|
    post.publish(command)
  end
end
```
_Note:_ the message-handling DSL (`process`) supports passing a super class of any given event
as well. Every `process` block that applies to the event will be called in order from most specific to least specific.

### Value Objects

Often times you will find that you will have data clumps that are similar pieces of data that have the same rules, and schema. Typically these values represent a valid type in your domain and should be combined as a single value. That is where `ValueObject` comes in. The api is the same as commands and events.

```ruby
class Name < Aggregates::ValueObject
  field :first_name, :last_name
  validates_presence_of :first_name, :last_name
end
```

When you have a command, validation logic will automatically include validating nested value objects to an arbitrary depth.


### Filtering Commands

There are times where commands should not be executed by the domain logic. You can opt to include a condition in your command processor or aggregate. However, that is not always extensible if you have repeated logic between many commands. Additionally, it violates the single responsibility principal.

Instead, it is best to support this kind of filtering logic using `CommandFilters`. A `CommandFilter` uses the same Message Handling message-handling DSL as the rest of the `Aggregates` gem. 
This time, it needs to return a true/false back to the gem to determine whether or not (true/false) the command should be allowed. Many command filters can provide many blocks of the `filter` or `on` DSL. 
If any one of the filters rejects the command then the command will not be processed.

```ruby
class UpdatePostCommand < Aggregates::Command
  interacts_with Post
  field :commanding_user_id
end

class UpdatePostBody < UpdatePostCommand
  field :body
end

class PostCommandFilter < Aggregates::CommandFilter
  # Instead of `filter`, you may use `on`
  filter UpdatePostCommand do |command, post|
    post.owner_id == command.commanding_user_id
  end
end
```

In this example, we are using a super class of `UpdatePostBody`.
As with all MessageProcessors, calling `filter` with a super class
will be called when any child class is being processed. In other words,
`on UpdatePostCommand` will be called when you call `Aggregates.execute_command`
with an instance of `UpdatePostBody`.

### Processing Events

Event processors are responsible for responding to events and effecting changes on things
that are not the aggregates themselves. Here is where the read side of your CQRS model can take
place. Since `Aggregates` does not enforce a storage solution for any component of the application, you will likely want to provide a helper mechanism for updating projections of aggregates into your read model.

Additionally, the `EventProcessor` type can be used to perform other side effects in other systems. Examples could include sending an email to welcome a user, publish the event to a webhook for a subscribing micro service, or much more.

```ruby
class RssUpdateProcessor < Aggregates::EventProcessor
  def update_feed_for_new_post(event)
    # ...
  end

  on PostPublished do |event|
    update_feed_for_new_post(event)
  end
end
```

_Note:_ the message-handling DSL (`on`) supports passing a super class of any given event
as well. Every `on` block that applies to the event will be called in order from most specific to least specific.

### Executing Commands

```ruby
aggregate_id = Aggregates.new_aggregate_id
command = CreateThing.new(foo: 1, bar: false, aggregate_id: aggregate_id)
Aggregates.execute_command command

increment = IncrementFooThing.new(aggregate_id: aggregate_id)
toggle = ToggleBarThing.new(aggregate_id: aggregate_id)
Aggregates.execute_commands increment, toggle
```

### Auditing Aggregates

```ruby
aggregate_id = Aggregates.new_aggregate_id
# ... Commands and stuff happened.
auditor = Aggregates.audit MyAggregateType aggregate_id

# Each of these returns a list to investigate using.
events = auditor.events # Or events_processed_by(time) or events_processed_after(time)
commands = auditor.commands # Or commands_processed_by(time) or commands_processed_after(time)

# Or....
# View the state of an aggregate at a certain pont in time.
aggregate_at_time = auditor.inspect_state_at(Time.now - 1.hour)
```

### Configuring

#### Storage Backends

Storage Backends at the method by which events and commands are stored in
the system.

```ruby
Aggregates.configure do |config|
  config.store_with MyAwesomeStorageBackend.new
end
```

##### Dynamoid

If `Aggregates` can `require 'dynamoid'` then it will provide the `Aggregates::Dynamoid::DynamoidStorageBackend` that
stores using the [Dynmoid Gem](https://github.com/Dynamoid/dynamoid) for AWS DynamoDB.

#### Adding Command Processors

```ruby
Aggregates.configure do |config|
  # May call this method many times with different processors.
  config.process_commands_with PostCommandProcessor.new
end
```

#### Adding Event Processors

```ruby
Aggregates.configure do |config|
  # May call this method many times with different processors.
  config.process_events_with RssUpdateProcessor.new
end
```

#### Adding Command Filters

```ruby
Aggregates.configure do |config|
  config.filter_commands_with MyCommandFilter.new
end
```

## Development

To contribute, run:

    git clone https://github.com/resilient-vitality/aggregates.git
    cd aggregates
    bin/setup

You can also use the IRB console for direct access to all objects:

    bin/console

## Tests

To test, run:

    bundle exec rake

## Versioning

Read [Semantic Versioning](https://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

Copyright 2021 [Resilient Vitality](www.resilientvitality.com).
Read [LICENSE](LICENSE.md) for details.

## History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://www.alchemists.io/projects/gemsmith).

## Credits

Developed by [Zach Probst](mailto:zprobst@resilientvitality.com) at [Resilient Vitality](www.resilientvitality.com).
