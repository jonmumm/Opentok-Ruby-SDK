# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{opentok}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["TokBox, Inc."]
  s.date = %q{2010-11-07}
  s.description = %q{The ruby implementation of the OpenTok API server-side API}
  s.email = ["melih@tokbox.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/OpenTok/OpenTokSDK.rb", "lib/OpenTok/Exceptions.rb", "lib/open_tok.rb", "tokboxer.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://www.opentok.com}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{opentok}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{The ruby implementation of the OpenTok API server-side API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.0.5"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.0.5"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.0.5"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
