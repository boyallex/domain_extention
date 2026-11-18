require 'xcodeproj'

path = File.expand_path('../ios/Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(path)
abort 'CharacterWidget target already exists' if project.targets.any? { |target| target.name == 'CharacterWidget' }
runner = project.targets.find { |target| target.name == 'Runner' }
development_team = runner.build_configurations.first.build_settings['DEVELOPMENT_TEAM']

widget = project.new_target(:app_extension, 'CharacterWidget', :ios, '15.0')
widget_group = project.main_group.new_group('CharacterWidget', 'CharacterWidget')
widget.add_file_references([widget_group.new_file('CharacterWidget.swift')])
widget.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  settings['CODE_SIGN_ENTITLEMENTS'] = 'CharacterWidget/CharacterWidget.entitlements'
  settings['DEVELOPMENT_TEAM'] = development_team if development_team
  settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  settings['INFOPLIST_FILE'] = 'CharacterWidget/Info.plist'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.domainExtention.CharacterWidget'
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['SKIP_INSTALL'] = 'YES'
  settings['SWIFT_VERSION'] = '5.0'
end

runner.build_configurations.each do |configuration|
  configuration.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
  configuration.build_settings['ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES'] = [
    'AppIconGojo',
    'AppIconSukuna',
  ]
end
runner.add_dependency(widget)
embed = runner.new_copy_files_build_phase('Embed App Extensions')
embed.dst_subfolder_spec = '13'
build_file = embed.add_file_reference(widget.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }

project.save
