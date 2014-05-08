require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send('disable_quoted_booleans')
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]

namespace :bootstrap do
  module_name = 'lmod'

  desc "Bootstrap spec files using project's name"
  task :spec, [:noop] do |t, args|
    noop = args[:noop]
    files =[]
    Dir[File.join('spec', '**', '*skeleton*.{rb,pp}')].each do |file|
      files << file
    end
  
    files.each do |file|
      file_new = File.join(File.dirname(file), File.basename(file).gsub(/skeleton/, module_name))
      stdout = "Renaming: #{file} ==> #{file_new}"
      stdout << " (noop)" if noop
      puts stdout
      File.rename(file, file_new) unless noop
    end
  end
end

desc 'Run all bootstrap tasks'
task :bootstrap, [:noop, :git_parent] do |t, args|
  args.with_defaults(:noop => false)
  # Set noop true if word noop is used
  args[:noop] == true if args[:noop] =~ /noop/
  Rake.application.in_namespace(:bootstrap) do |b|
    b.tasks.each do |task|
      Rake::Task[task].invoke(args[:noop])
    end
  end
  Rake::Task['git:init'].invoke(args[:noop], args[:git_parent])
end

# REF: https://github.com/Arcath/Rake-Tasks
namespace :git do
  desc "Perform git init and connect to a parent"
  task :init, [:noop, :parent] do |t, args|
    next if args[:noop]
    system('git init')
    system('git add .')
    if args[:parent]
      system("git remote add origin #{args[:parent]}")
    end
  end
end

# REF: https://gist.github.com/indirect/2922427
namespace :source do
  def find_and_replace_in_source_files(find, replace)
    puts "Search and replace #{find.inspect} => #{replace.inspect}"
 
    files = %w[ .autotest .rspec .rvmrc Gemfile Procfile config.ru ].select{|f| File.exist?(f) }
    directories = %w[manifests files templates lib spec test] # exclude bin, db, doc, log, and tmp
    directories.each do |d|
      files += Dir[File.join(d, "**/*.{pp,erb,rb}")]
    end
 
    files.each do |file_name|
      text = File.open(file_name, 'r'){ |file| file.read }
      if text.gsub!(find, replace)
        puts "rewriting #{file_name}..."
        File.open(file_name, 'w'){|file| file.write(text)}
      end
    end
  end
 
  desc "Replace all tabs in source code files with two spaces"
  task :detab do
    find_and_replace_in_source_files("\t", "  ")
  end
 
  desc "Remove trailing whitespace on the ends of lines"
  task :detrail do
    find_and_replace_in_source_files(/ +$/, '')
  end
 
  desc "Replace all instances of {pattern} with {result}"
  task :gsub, :pattern, :result do |t, args|
    find_and_replace_in_source_files(Regexp.new(args[:pattern] || ENV['PATTERN']), args[:result] || ENV['RESULT'])
  end
end
