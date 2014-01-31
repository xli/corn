Gem::Specification.new do |s|
  s.name = 'corn'
  s.version = '0.0.10'
  s.summary = 'Corn is a test benchmarking tool.'
  s.description = <<-EOF
Corn injects hook to test frameworks for collecting test running benchmark reports. It submits reports to Corn Server after all tests finished.
EOF
  s.license = 'MIT'
  s.authors = ["Xiao Li"]
  s.email = ['swing1979@gmail.com']
  s.homepage = 'https://github.com/xli/corn'

  s.files = ['README.md']
  s.files += Dir['lib/**/*.rb']
end
