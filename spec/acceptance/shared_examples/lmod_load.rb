def shell_paths
  case fact('osfamily')
  when 'Debian'
    [
      '/etc/profile.d/modules.sh',
      '/etc/csh/login.d/modules.csh',
      '/etc/profile.d/z00_StdEnv.sh',
      '/etc/csh/login.d/z00_StdEnv.csh',
    ]
  else
    [
      '/etc/profile.d/modules.sh',
      '/etc/profile.d/modules.csh',
      '/etc/profile.d/z00_StdEnv.sh',
      '/etc/profile.d/z00_StdEnv.csh',
    ]
  end
end

shared_examples_for 'lmod::load' do
  shell_paths.each do |file|
    describe file(file) do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
