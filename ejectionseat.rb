cask 'ejectionseat' do
  version '1.5.0'
  sha256 "d323e3491fe71807e746b5b7629d1bb41d05fa560e2a55c75e4476213630ecc9"

  url "https://github.com/pilotchute/EjectionSeat/releases/download/#{version}/EjectionSeat.zip"
  appcast 'https://github.com/pilotchute/EjectionSeat/releases.atom'
  name 'EjectionSeat'
  homepage 'https://github.com/pilotchute/EjectionSeat'

  app 'EjectionSeat.app'
end
