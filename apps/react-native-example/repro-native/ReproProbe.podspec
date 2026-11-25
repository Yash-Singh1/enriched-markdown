Pod::Spec.new do |s|
 s.name='ReproProbe';s.version='1.0.0';s.summary='Local native exporter repro';s.homepage='https://github.com/software-mansion/enriched-markdown';s.license='MIT';s.author='Local';s.source={:git=>'https://github.com/software-mansion/enriched-markdown'};s.platform=:ios,'15.1';s.source_files='*.{h,mm}';s.dependency 'React-Core';s.dependency 'ReactNativeEnrichedMarkdown';s.pod_target_xcconfig={'HEADER_SEARCH_PATHS'=>'$(inherited) "$(PODS_TARGET_SRCROOT)/../../../packages/react-native-enriched-markdown/ios/**"'}
end
