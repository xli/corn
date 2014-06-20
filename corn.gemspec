Gem::Specification.new do |s|
  s.name = 'corn'
  s.version = '0.5.0'
  s.summary = 'Corn submits profiling data to Corn server.'
  s.description = <<-EOF
Corn collects your application's profiling data by sampling_prof gem, and submits the result to Corn server for analysis.
EOF
  s.license = 'MIT'
  s.authors = ["Xiao Li"]
  s.email = ['swing1979@gmail.com']
  s.homepage = 'https://github.com/xli/corn'

  s.add_runtime_dependency('sampling_prof', '>= 0.4.5')

  s.files = ['README.md']
  s.files += Dir['lib/**/*.rb']
end
