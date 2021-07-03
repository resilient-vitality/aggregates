# frozen_string_literal: true

require_relative "lib/aggregates/identity"

Gem::Specification.new do |spec|
  spec.name = Aggregates::Identity::NAME
  spec.version = Aggregates::Identity::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Zach Probst"]
  spec.email = ["zprobst@resilientvitality.com"]
  spec.homepage = "https://github.com//aggregates"
  spec.summary = ""
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com//aggregates/issues",
    "changelog_uri" => "https://github.com//aggregates/blob/master/CHANGES.md",
    "documentation_uri" => "https://github.com//aggregates",
    "source_code_uri" => "https://github.com//aggregates"
  }

  spec.required_ruby_version = "~> 3.0"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
