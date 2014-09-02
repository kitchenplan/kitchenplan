guard 'rspec', :all_on_start => false, :all_after_pass => false, :cmd => 'rspec --color --fail-fast --profile 5 --format documentation' do
watch(%r{^lib/(.+)\.rb$}) do |m|
"spec/#{m[1]}_spec.rb"
end
watch(%r{^spec/(.+)\.rb$}) do |m|
"spec/#{m[1]}.rb"
end
end

