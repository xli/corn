Gem::Specification.new do |s|
  s.name = 'corn'
  s.version = '0.1.0'
  s.summary = 'Corn is a simple benchmark report tool.'
  s.description = <<-EOF
Corn provides simple api for collecting benchmark reports and submits reports to Corn Server.
EOF
  s.license = 'MIT'
  s.authors = ["Xiao Li"]
  s.email = ['swing1979@gmail.com']
  s.homepage = 'https://github.com/xli/corn'

  s.files = ['README.md']
  s.files += Dir['lib/**/*.rb']
end
