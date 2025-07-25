# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2018-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'
Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>=2.5'
  s.name = 'zold-ruby-sdk'
  s.version = '0.0.0'
  s.license = 'MIT'
  s.summary = 'Zold score'
  s.description = 'Ruby SDK for Zold online wallets management system (WTS)'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'https://github.com/zold-io/zold-ruby-sdk'
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_runtime_dependency 'loog', '~>0.2'
  s.add_runtime_dependency 'typhoeus', '1.4.0'
  s.add_runtime_dependency 'zold', '~>0.31'
  s.metadata['rubygems_mfa_required'] = 'true'
end
