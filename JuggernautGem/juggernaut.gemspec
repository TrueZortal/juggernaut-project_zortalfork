Gem::Specification.new do |spec|
  spec.name          = "juggernaut"
  spec.version       = "0.0.1"
  spec.authors       = ["Dawid Warpas", "Mateusz Buczek"]
  spec.email         = ""
  spec.summary       = "A brief description of your gem"
  spec.description   = "A longer description of your gem"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir.glob("{lib}/**/*")  # List of files to include
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.require_paths = ["lib"]

  spec.add_dependency 'faraday'
  spec.add_dependency 'googleauth'
  spec.add_dependency 'google-apis-calendar_v3'
  spec.add_dependency 'google-apis-sheets_v4'
  spec.add_dependency 'json'
  spec.add_dependency 'fileutils'
  spec.add_dependency 'date'

  # spec.add_dependency 'rspec'
  # spec.add_dependency 'standard'
end
