shared_examples_for 'lmod::load' do
  [
    '/etc/profile.d/modules.sh',
    '/etc/profile.d/modules.csh',
  ].each do |file|
    describe file(file) do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end

  [
    '/etc/profile.d/z00_StdEnv.sh',
    '/etc/profile.d/z00_StdEnv.csh',
  ].each do |file|
    describe file(file) do
      it { should_not be_file }
    end
  end
end