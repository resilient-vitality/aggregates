# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/audit/task'
require 'gemsmith/rake/setup'
require 'git/lint/rake/setup'
require 'reek/rake/task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Bundler::Audit::Task.new
Reek::Rake::Task.new
RSpec::Core::RakeTask.new :spec
RuboCop::RakeTask.new

desc 'Run code quality checks'
task code_quality: %i[bundle:audit reek rubocop]

task default: %i[code_quality spec]
