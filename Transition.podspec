Pod::Spec.new do |s|
  s.name             = 'Transition'
  s.version          = '1.0.1'
  s.summary          = 'Easy interactive interruptible custom ViewController transitions.'

  s.description      = <<-DESC
Transition makes building interactive interruptible custom view controller transitions easy! You just define the animation and interaction, Transition ties it all together.
                       DESC

  s.homepage         = 'https://github.com/Touchwonders/Transition'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors            = { "Toine Heuvelmans" => "toine@touchwonders.com", "Robert-Hein Hooijmans" => "robert-hein@touchwonders.com" }
  s.social_media_url   = "https://twitter.com/touchwonders"
  s.source           = { :git => 'https://github.com/Touchwonders/Transition.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.platform     = :ios, '10.0'

  s.source_files = 'Transition/Classes/**/*'
end
