Gem::Specification.new do |s|
  s.name        = 'tinderfish'
  s.version     = '0.0.1'
  s.licenses    = ['MIT']
  s.summary     = "Catfish Guys with the Tinder API"

  s.description = """
    Tinderfish uses Neal Kemp's ruby implementation of the reverse engineered
    Tinder API to relay messages between two victim profiles through a fake
    profile. As far as the victims are concerned, they're talking to a match. In
    reality, they're talking directly to each other thanks to
    Tinderfish.
  """

  s.authors     = ["Spencer Dixon", "Andrea Rossi"]
  s.email       = ''
  s.files       = Dir['lib/**/*.rb']
  s.bindir      = 'bin'
  s.executables << 'tinderfish'
end

